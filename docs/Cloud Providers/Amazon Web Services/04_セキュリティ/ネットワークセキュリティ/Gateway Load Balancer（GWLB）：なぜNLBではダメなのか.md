<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: Gateway Load Balancer（GWLB）：なぜ NLB ではダメなのか -->

# Gateway Load Balancer（GWLB）：なぜ NLB ではダメなのか

## パケットインスペクションが必要になる場面

社内ネットワークとクラウドの境界に Palo Alto や Fortinet のような商用ファイアウォールを置きたい。あるいは IDS/IPS を全 VPC トラフィックにかませたい。こういう要件を初めて受けたとき、「NLB の後ろにアプライアンスを置けばいいのでは」と思うのは自然な発想だ。

結論から言うと、**NLB では「インライン検査」にならない**。GWLB が必要な理由はここにある。

---

## NLB で何が起きるか

NLB はシンプルな L4 ロードバランサーで、クライアントから来た TCP/UDP パケットをバックエンドのターゲットに振り分ける。

パケットインスペクションの文脈で NLB を使おうとすると、以下の構成を考えるかもしれない。

```
Internet → IGW → NLB → Appliance → ???
```

**問題はアプライアンスの「その先」だ。**

NLB はトラフィックをアプライアンスに届けることはできる。しかし NLB はルートテーブルのターゲットにはなれない。つまり「VPC を出入りするすべてのパケットを透過的に NLB 経由にする」という設定が書けない。

さらに深刻なのが**戻りパケットの問題**だ。

アプライアンスがパケットを検査した後、そのパケットを宛先（例: EC2 インスタンス）に転送する。EC2 からの応答パケットはどこに戻るか。NLB ではこの戻りのパスを制御できない。EC2 からの応答は直接 IGW に抜けてしまい、アプライアンスを迂回する。送りは検査、戻りは素通りという矛盾した状態になる。

これを「非対称ルーティング」と呼ぶ。ステートフルなファイアウォールやセッションを追う IPS は、この状態でセッションを正しく追えず、正規の通信を誤ってドロップする。

---

## GWLB が解決する 2 つのこと

GWLB は「透過的なバンプインザワイヤ」を実現するために設計されている。NLB との本質的な違いは 2 点。

### 1. ルートテーブルのターゲットになれる

GWLB は **Gateway Load Balancer Endpoint（GWLBe）** という VPC エンドポイントをスポーク VPC 側に置く。この GWLBe をルートテーブルのネクストホップに指定できる。

```
# スポーク VPC のルートテーブル（インターネット向けサブネット）
0.0.0.0/0 → gwlbe-xxxxx   ← GWLBe をネクストホップに指定
```

これにより、「VPC を出るすべてのパケット」をアプライアンスに強制的に通せる。NLB には同等の仕組みがない。

### 2. GENEVE カプセル化で元の IP ヘッダーを保持する

アプライアンスはパケットの送信元・宛先 IP を見てポリシーを判断する。ところが通常のロードバランシングでは、アプライアンスから見た「送信元 IP」はロードバランサーの IP になってしまう。

GWLB は **GENEVE（Generic Network Virtualization Encapsulation）** プロトコルを使って元のパケットをトンネリングする。

```
[外側ヘッダー]
  送信元: GWLB の IP
  宛先:   Appliance の IP
  ポート: UDP 6081 (GENEVE)

[GENEVE ヘッダー]（メタデータ）
  フローのコンテキスト情報

[内側ヘッダー（元のパケット）]
  送信元: 実際のクライアント IP
  宛先:   実際のサーバー IP
  ペイロード: 元の通信内容
```

アプライアンスは内側の本物の IP ヘッダーを見てポリシー判断できる。検査が終わったら同じ GENEVE トンネルで GWLB に返す。GWLB がカプセルを外して、元のパケットを正しい宛先に届ける。

---

## パケットの往復がどう変わるか

GWLB を使ったときのパケットの流れは以下のようになる。

```
【送り方向（クライアント → サーバー）】
Internet
  → IGW
  → GWLBe（ルートテーブルのエントリでここに曲げられる）
  → GWLB（GENEVE でカプセル化）
  → Appliance（内側の元 IP を見て検査・許可）
  → GWLB（カプセルを外す）
  → GWLBe
  → Application Subnet の EC2

【戻り方向（サーバー → クライアント）】
EC2
  → GWLBe（ルートテーブルのエントリで曲げられる）
  → GWLB（同じフローなので同じ Appliance インスタンスへ）
  → Appliance（セッションを追って検査）
  → GWLB
  → GWLBe
  → IGW
  → Internet
```

往復とも同じアプライアンスを通る。GWLB は 5 タプル（送信元 IP・ポート、宛先 IP・ポート、プロトコル）を使ってスティッキールーティングするため、ステートフルな検査が成立する。

---

## NLB との比較まとめ

| 観点 | NLB | GWLB |
|---|---|---|
| ルートテーブルのターゲットになれるか | ✗ | ○（GWLBe 経由） |
| 透過的なバンプインザワイヤ | ✗ | ○ |
| 元の IP ヘッダーをアプライアンスに見せられるか | ✗ | ○（GENEVE） |
| 戻りパスも同じアプライアンスを通るか | ✗ | ○（スティッキールーティング） |
| アプライアンスのスケーリング | ○（ターゲットグループで水平スケール） | ○（同様） |

NLB が劣っているのではなく、**NLB はパケットインスペクションのユースケースを想定して設計されていない**。NLB は単純な L4 負荷分散に適しており、透過的なインライン検査には GWLB が必要、という棲み分けになる。

---

## AWS Network Firewall との使い分け

GWLB を使うかどうかは、**既存のアプライアンスを持っているかどうか**が分岐点になることが多い。

```
既存の商用 Appliance を持っている（Palo Alto・Fortinet 等）
  → GWLB + サードパーティ製品
  → ポリシーをオンプレと統一できる

AWS ネイティブで新規に始める
  → AWS Network Firewall（内部的に GWLB の仕組みを使っている）
  → アプライアンスの OS・パッチ管理が不要
```

AWS Network Firewall 自体も GWLB の仕組みの上に構築されている。つまり「透過的なバンプインザワイヤ + GENEVE」は Network Firewall を選んでも GWLB を選んでも同じ技術基盤で動いている。フルマネージドにするか、商用製品の機能をそのまま使うかの選択だ。

---

## 参考

- [Gateway Load Balancer の概要 - AWS ドキュメント](https://docs.aws.amazon.com/elasticloadbalancing/latest/gateway/introduction.html)
- [Centralized inspection architecture with AWS Gateway Load Balancer and AWS Transit Gateway - AWS Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/centralized-inspection-architecture-with-aws-gateway-load-balancer-and-aws-transit-gateway/)
- [Gateway Load Balancer endpoints - AWS ドキュメント](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-load-balancer-endpoints.html)
- [GENEVE: Generic Network Virtualization Encapsulation - RFC 8926](https://www.rfc-editor.org/rfc/rfc8926)
- [Scaling network traffic inspection using AWS Gateway Load Balancer - AWS Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/scaling-network-traffic-inspection-using-aws-gateway-load-balancer/)
