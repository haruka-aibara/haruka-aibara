# Netfilter

「サービスは動いているのに外から接続できない」——セキュリティグループは開けたはず。そんなとき最後に疑う場所が、ホスト自身のファイアウォール。Linux でそれを担うカーネル側の仕組みが Netfilter で、iptables や nftables、firewalld、そして Docker のポート公開も、全部この上に乗っている。

## Netfilter は「パケットの通り道に仕掛けたフック」

カーネル内をパケットが通過する経路には5つのフック地点（prerouting / input / forward / output / postrouting）があり、そこにルールを引っ掛けて「通す・捨てる・書き換える」を行うのが Netfilter の仕組み。

- 自分宛のパケットは **input** を通る → ここが着信ファイアウォール
- 転送するパケットは **forward** を通る → ルーターとして動くときの制御点
- NAT（アドレス書き換え）は prerouting / postrouting で行う → Docker がコンテナのポートを公開するのもこれ

ルールを操作するツールが歴史的に iptables、現行の後継が **nftables**（iptables コマンドは互換レイヤーとして残っている）。firewalld（RHEL系）や ufw（Ubuntu）は、これらを人間向けに包んだフロントエンド。

## まず「いま何が効いているか」を見る

冒頭の切り分けはこの確認から：

```bash
sudo nft list ruleset        # nftables のルール全部（現代の環境はまずこれ）
sudo iptables -L -n -v       # iptables 互換ビュー。-v でマッチしたパケット数が見える
```

`-v` のパケットカウンタが実は優秀で、「DROP ルールのカウンタが増えている＝そこで落ちている」と動かぬ証拠が取れる。

ufw / firewalld 管理の環境ならフロントエンド側で見るほうが読みやすい：

```bash
sudo ufw status verbose            # Ubuntu
sudo firewall-cmd --list-all       # RHEL 系
```

## ルールを書くときの基本形

直接 nft/iptables を書くより、入っているフロントエンドを使うのが管理上は無難。例（ufw）：

```bash
sudo ufw allow 22/tcp        # SSH を許可
sudo ufw allow from 10.0.0.0/8 to any port 5432   # 社内からのみ DB を許可
sudo ufw enable
```

リモートのサーバーで有効化するときは、**先に SSH の許可ルールを入れてから** enable する。この順番を間違えて自分を閉め出すのは、全員が一度は通る道。

## クラウドでの位置づけ

AWS ではセキュリティグループ／ネットワーク ACL がインスタンスの手前で同じ役割を果たすので、ホスト内の Netfilter は「二重目の防御」になる。役割が重複して見えるが、SG は「インスタンスの外」、Netfilter は「OS の中」の制御であり、コンテナ間通信や侵害後の横移動の制限はホスト側でしか書けない。「SG があるから ufw は不要」と単純には言えない、と押さえておく。

## 参考

- [nftables wiki — netfilter.org](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page)
- [nft(8) — man7.org](https://man7.org/linux/man-pages/man8/nft.8.html)
- [UFW — Ubuntu Server documentation](https://documentation.ubuntu.com/server/how-to/security/firewalls/)
