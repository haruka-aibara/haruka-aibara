# DPD（Dead Peer Detection）とは

AWS Site-to-Site VPN を使っていると「トンネルは Up なのに通信できない」という状態に陥ることがある。原因の一つが、相手側が死んでいるのに気づかず古いセッションを保持し続けていること。DPD はこの問題を解決する仕組みだ。

## 何が問題か

IPsec トンネルを張るとき、両端は IKE（Internet Key Exchange）でセキュリティアソシエーション（SA）を確立し、鍵情報を共有する。問題は、**SA が確立した後は定期的なハートビートがない**ことだ。

相手（オンプレの VPN 機器や AWS 側）が再起動・障害で落ちても、こちら側は SA を保持したまま「つながっている」と思い込む。この状態でトラフィックを送るとブラックホールになる。

## DPD の仕組み

DPD は RFC 3706 で定義された IKE の拡張機能。一定時間トラフィックがない相手に対して **R-U-THERE** メッセージを送り、応答の有無で生死を確認する。

- 応答あり → セッション継続
- 応答なし（タイムアウト） → SA を削除してトンネルをクリア

## AWS Site-to-Site VPN での設定

AWS の VPN トンネルでは DPD がデフォルトで有効。タイムアウト時のアクションを 3 種類から選べる。

| アクション | 動作 |
|---|---|
| `clear`（デフォルト） | SA を削除。再接続はオンプレ側からのトラフィック待ち |
| `restart` | SA を削除後、即座に IKE ネゴシエーションを再開 |
| `none` | タイムアウトしても何もしない |

```bash
# トンネルオプションの確認
aws ec2 describe-vpn-connections \
  --query 'VpnConnections[*].Options.TunnelOptions[*].[DpdTimeoutAction,DpdTimeoutSeconds]'
```

### `clear` のハマりポイント

デフォルトの `clear` を使っていると、DPD タイムアウト後にトンネルがクリアされる。AWS の Site-to-Site VPN はオンプレ側から接続を開始するのが基本のため、**AWS 側からオンプレへの通信が発生するまでトンネルが再確立されない**ことがある。

オンプレ → AWS 方向の通信しかない環境や、フェイルオーバー後に AWS 側からすぐ通信したい場合は `restart` を選ぶほうがいい。

## オンプレ側の設定も合わせる

DPD は両端が対応していて初めて機能する。AWS 側で有効にしても、オンプレの VPN 機器（Cisco ASA、Fortinet 等）で DPD を無効にしていると正常に動作しない。

Cisco IOS の例：

```
crypto isakmp keepalive 10 3 periodic
# 10秒間隔で送信、3回応答なしでタイムアウト
```

## 確認・トラブルシュート

```bash
# VPN 接続のトンネル状態
aws ec2 describe-vpn-connections \
  --query 'VpnConnections[*].VgwTelemetry[*].[OutsideIpAddress,Status,StatusMessage]'

# CloudWatch メトリクス: TunnelState (1=Up, 0=Down)
aws cloudwatch get-metric-statistics \
  --namespace AWS/VPN \
  --metric-name TunnelState \
  --dimensions Name=VpnId,Value=<vpn-id> \
  --start-time $(date -u -d '1 hour ago' +%FT%TZ) \
  --end-time $(date -u +%FT%TZ) \
  --period 60 \
  --statistics Average
```

## 参考

- [Site-to-Site VPN tunnel options - AWS](https://docs.aws.amazon.com/vpn/latest/s2svpn/VPNTunnels.html)
- [RFC 3706 - A Traffic-Based Method of Detecting Dead Internet Key Exchange (IKE) Peers](https://datatracker.ietf.org/doc/html/rfc3706)
