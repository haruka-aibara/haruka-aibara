# TCP/IPスタック

「つながらない」という報告は、DNS の失敗、経路の問題、ファイアウォール、アプリの停止のどれでも同じ顔をしてやってくる。切り分けの土台になるのが TCP/IP の層の理解——「どの層で死んでいるか」を特定できれば、調査対象は一気に絞れる。

## 4層モデルと「どこで死んでいるか」

| 層 | 担当 | ここで死んでいるときの症状の例 |
|---|---|---|
| アプリケーション | HTTP, DNS, SSH | ポートは開くがエラー応答が返る |
| トランスポート | TCP, UDP | connection refused / timeout |
| インターネット | IP, ICMP, ルーティング | ping が届かない、経路がない |
| ネットワークインターフェース | Ethernet, ARP | リンクダウン、同一セグメントでも届かない |

調査は下から上へ、が基本線。リンクは上がっているか（`ip link`）→ IP は付いているか（`ip addr`）→ 経路はあるか（`ip route`、ping）→ ポートは開いているか、と積み上げる。

## TCP と UDP の違いは「確実さの責任を誰が持つか」

- **TCP**: コネクションを張り（3ウェイハンドシェイク）、届いたことを確認し、順序を保証する。HTTP、SSH、データベース接続など大半はこれ
- **UDP**: 投げっぱなし。速いが届く保証はしない。DNS クエリ、NTP、メトリクス送信など「失われても再送すればいい」ものに使う

切り分けで効くのは、**TCP の失敗には2種類ある**という点。

- `connection refused`: 相手ホストまでは届いていて、そのポートで誰も待っていない（RST が即返る）→ サービス側の問題
- `timeout`: そもそも応答が来ない → 経路かファイアウォールが疑わしい（パケットを黙って捨てる設定だとこうなる）

この2つを区別するだけで「アプリを見るべきか、ネットワークを見るべきか」が決まる。

## 現在の接続状態を見る

```bash
ss -tulnp      # LISTEN しているポートとプロセス（netstat -at の現代版）
ss -t state established   # 確立済みの TCP 接続
```

`ss` の出力にある State（LISTEN / ESTAB / TIME-WAIT / SYN-SENT など）は TCP の状態遷移そのもの。たとえば SYN-SENT が積み上がっていたら「SYN を送ったのに応答がない」＝相手方かファイアウォールの問題、と読める。

## 参考

- [ss(8) — man7.org](https://man7.org/linux/man-pages/man8/ss.8.html)
- [RFC 9293: Transmission Control Protocol (TCP)](https://datatracker.ietf.org/doc/html/rfc9293)
- [tcp(7) — man7.org](https://man7.org/linux/man-pages/man7/tcp.7.html)
