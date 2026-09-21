# DNS64 と NAT64

## どんな場面で必要になるか

AWS VPC を IPv6 シングルスタック（IPv4 なし）で構成すると、コンテナや EC2 インスタンスに IPv4 アドレスが割り当てられない。ここで困るのが、IPv4 しか持っていない外部サービスへのアウトバウンド通信だ。

例えば：

- S3 の VPC エンドポイントを使わずパブリック S3 に接続したい
- サードパーティ API のドメインが AAAA レコードを持っていない
- npm / pip などのパッケージレジストリへのアクセス

「IPv6 しかない環境から IPv4 しかないホストへ通信する」という問題をソフトウェアだけで解決するのが DNS64 + NAT64 の組み合わせだ。

---

## しくみ

### DNS64 の役割

DNS64 は名前解決の段階で介入する。

クライアントが `example.com` の AAAA レコードを問い合わせたとき：

1. 権威 DNS を引く → AAAA レコードがない（A レコードのみ）
2. DNS64 が A レコード（例: `93.184.216.34`）を取得
3. 合成 AAAA レコードを作成して返す（例: `64:ff9b::93.184.216.34`）

クライアントは「IPv6 アドレスで応答が返ってきた」と認識するので、IPv6 で通信を開始する。

### NAT64 の役割

DNS64 が返した合成アドレス（`64:ff9b::/96` プレフィックス）宛のパケットは、NAT64 ゲートウェイに到達する。NAT64 がそのパケットを IPv4 パケットに変換し、元の IPv4 サーバー（`93.184.216.34`）に転送する。

```
IPv6 クライアント
  │
  │  dst: 64:ff9b::93.184.216.34 (IPv6)
  ▼
NAT64 ゲートウェイ
  │
  │  dst: 93.184.216.34 (IPv4 に変換)
  ▼
IPv4 サーバー
```

クライアントは IPv4 の存在を意識せずに通信できる。

---

## AWS での実装

AWS VPC では DNS64 と NAT64 をマネージドサービスとして提供している。

### Route 53 Resolver の DNS64

VPC のサブネット単位で DNS64 を有効化できる。有効にすると、そのサブネットの Route 53 Resolver（`169.254.0.2` / `fd00:ec2::253`）が DNS64 として機能する。

```
# AWS CLI でサブネットの DNS64 を有効化
aws ec2 modify-subnet-attribute \
  --subnet-id subnet-xxxxxxxx \
  --enable-dns64
```

### NAT64 ゲートウェイ

NAT64 は通常の NAT ゲートウェイが兼ねる。IPv6 専用サブネットのルートテーブルに以下を追加する：

| 送信先 | ターゲット |
|---|---|
| `64:ff9b::/96` | NAT ゲートウェイ（nat-xxxxxxxx） |

これで合成アドレス宛のトラフィックが NAT ゲートウェイ経由で IPv4 に変換される。

---

## DNS64 が効かないケース

- **ハードコードされた IPv4 アドレス**: DNS を経由しないため DNS64 は介入できない。コード中の IP アドレス直書きは IPv6 環境で通信不能になる
- **DNSSEC 検証済みドメイン**: 合成レコードは署名がないため、DNSSEC を強制検証する環境では拒否される
- **IPv4 専用プロトコルのペイロード**: アプリケーション層で IPv4 アドレスを交換するプロトコル（古い FTP の PASV モード等）は別途対処が必要

---

## まとめ

| コンポーネント | 役割 |
|---|---|
| DNS64 | A レコードから合成 AAAA レコードを生成する |
| NAT64 | `64:ff9b::/96` 宛の IPv6 パケットを IPv4 に変換して転送する |

IPv6 シングルスタック構成を選ぶと IP 管理が単純になる一方、既存の IPv4 サービスとの互換性確保が課題になる。DNS64 + NAT64 はその橋渡しをするための標準的な手段だ。

---

## 参考

- [RFC 6146 – Stateful NAT64: Network Address and Protocol Translation from IPv6 Clients to IPv4 Servers](https://datatracker.ietf.org/doc/html/rfc6146)
- [RFC 6147 – DNS64: DNS Extensions for Network Address Translation from IPv6 Clients to IPv4 Servers](https://datatracker.ietf.org/doc/html/rfc6147)
- [AWS - Enable DNS64 and NAT64 for IPv6 communication](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-nat64-dns64.html)
- [AWS - IPv6 support for VPCs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-migrate-ipv6.html)
