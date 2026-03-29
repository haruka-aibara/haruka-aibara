<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: DNSゾーン転送：内部情報が外に漏れる仕組みと対策 -->

# DNSゾーン転送：内部情報が外に漏れる仕組みと対策

## 問題：DNSは「地図」になりうる

侵入者が最初にやることのひとつは、ターゲットの内部構成を把握することだ。どんなサブドメインが存在するか、どのホストがどのIPを持っているか——これが分かれば次の攻撃対象を絞れる。

DNSに「ゾーン転送」という機能が誤って公開されていると、その地図をまるごと渡してしまう。

---

## ゾーン転送とは何か

DNS のゾーン転送（AXFR: Authoritative Transfer）は、**プライマリ DNS サーバーからセカンダリ DNS サーバーへゾーンデータを複製するための仕組み**だ。

```
プライマリ DNS ──AXFR──▶ セカンダリ DNS
  (example.com の全レコード)
```

本来の用途は冗長化。プライマリが落ちてもセカンダリが応答できるよう、定期的にレコード一覧をコピーする。

問題は、この仕組みが「誰にでも応答する」設定になっていると、攻撃者も同じリクエストを送ってゾーン全体を取得できてしまう点にある。

---

## 何が漏れるのか

ゾーン転送が成功すると、そのドメインに紐づく**すべての DNS レコード**が手に入る。

```bash
# 攻撃者がやること（dig コマンドで AXFR リクエスト）
$ dig axfr example.com @ns1.example.com

; <<>> DiG <<>> axfr example.com
example.com.        3600  IN  SOA   ns1.example.com. ...
example.com.        3600  IN  NS    ns1.example.com.
example.com.        3600  IN  NS    ns2.example.com.
www.example.com.    300   IN  A     203.0.113.10
mail.example.com.   300   IN  A     203.0.113.20
dev.example.com.    300   IN  A     10.0.1.5       ← 開発環境
internal.example.com. 300 IN  A     192.168.0.100  ← 内部ホスト
vpn.example.com.    300   IN  A     203.0.113.30   ← VPN エンドポイント
...
```

これが侵害前偵察（Reconnaissance）として使われる。「dev.example.com が社内 IP に向いている」とか「vpn.example.com が存在する」という情報は、次の攻撃の糸口になる。

---

## なぜ今も問題になるのか

設定ミスが原因だが、「気づかない」ケースが多い。

- 昔のサーバー設定をそのまま引き継いだ
- `allow-transfer` を設定しないと BIND のデフォルトは全許可
- 外部向け DNS と内部向け DNS を分離していない（スプリット DNS をしていない）

ゾーン転送の設定漏れは、OWASP の情報収集手法でも言及されるほど古典的な問題でありながら、いまだに見つかる。

---

## 対策

### 1. ゾーン転送を許可するホストを明示的に制限する

BIND の場合：

```text
// named.conf
zone "example.com" {
    type master;
    file "/etc/bind/zones/example.com";
    allow-transfer { 203.0.113.5; };  // セカンダリ DNS の IP のみ許可
};
```

デフォルトで全許可なので、**セカンダリが不要なら `allow-transfer { none; };` にする**。

### 2. スプリット DNS を使う

外部向け DNS（インターネットに公開）と内部向け DNS（社内のみ）を分離する。外部 DNS には `www`、`mail` など最小限のレコードだけ置き、内部ホストのレコードは外部 DNS に乗せない。

```
外部 DNS（公開）     内部 DNS（社内のみ）
  www.example.com     dev.example.com
  mail.example.com    internal.example.com
                      vpn.example.com
```

### 3. 定期的に自分でテストする

```bash
# 自社ドメインに対して AXFR が通るか確認する
$ dig axfr example.com @<自社 DNS の IP>

# 成功してしまう場合 → 設定を見直す
# "Transfer failed." が返れば適切に制限されている
```

ペネトレーションテストや定期的なセキュリティチェックの項目に入れておくべき確認事項のひとつ。

---

## AWS Route 53 の場合

Route 53 はマネージドサービスであり、**AXFR リクエストには応答しない**。ゾーン転送の設定ミスは起きない。

```bash
$ dig axfr example.com @ns-xxx.awsdns-xx.com
; Transfer failed.
```

ただし Route 53 を使っていても、以下の点は別途確認が必要：

- **オンプレや EC2 上で動かしている BIND/PowerDNS** など自前 DNS の設定
- Route 53 Resolver（条件付き転送）の向き先となる社内 DNS サーバーの設定

Route 53 を使っているから安心、ではなくハイブリッド構成の場合は DNS チェーン全体を見る必要がある。

---

## まとめ

| 確認ポイント | 内容 |
|---|---|
| ゾーン転送の許可範囲 | セカンダリ DNS の IP のみに制限（またはすべて無効） |
| スプリット DNS | 内部ホストのレコードを外部 DNS に乗せていないか |
| 定期確認 | `dig axfr` で実際にテストする |
| AWS 利用時 | Route 53 はデフォルト安全。自前 DNS が混在する場合は別途確認 |

ゾーン転送の設定ミスは単体で見ると「情報が漏れる」だけに見えるが、漏れた情報が次の攻撃（フィッシング、脆弱なホストへの直接攻撃）の起点になる。侵害前の準備段階で塞いでおきたい。

---

## 参考

- [RFC 5936 - DNS Zone Transfer Protocol (AXFR)](https://datatracker.ietf.org/doc/html/rfc5936)
- [ISC BIND 9 Administrator Reference Manual - allow-transfer](https://bind9.readthedocs.io/en/latest/reference.html#namedconf-statement-allow-transfer)
- [OWASP Testing Guide - DNS Zone Transfer (OTG-INFO-001)](https://owasp.org/www-project-web-security-testing-guide/v42/4-Web_Application_Security_Testing/01-Information_Gathering/02-Fingerprint_Web_Server)
- [Amazon Route 53 Developer Guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)
