<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: Route 53 Resolver DNS Firewall：VPCからの不審なDNSをブロックする -->

# Route 53 Resolver DNS Firewall：VPCからの不審なDNSをブロックする

## 問題：マルウェアが「DNS を使って」外と通信する

EC2 インスタンスが侵害されたとき、攻撃者はそのインスタンスから外部の C2（Command & Control）サーバーに通信させようとする。このとき、HTTP や HTTPS を直接ブロックしてもすり抜ける手口がある——**DNS を使った通信**だ。

DNS クエリは多くの環境で「通って当然」とされていてフィルタリングされていない。ドメイン名に情報を埋め込んで外に送ったり（DNS トンネリング）、C2 サーバーのドメインを引いて接続先 IP を得たりする。

Route 53 Resolver DNS Firewall は、この「DNS 通信」の出口を VPC レベルで制御する仕組みだ。

---

## Route 53 Resolver DNS Firewall とは

VPC 内のリソース（EC2、Lambda、コンテナ等）が外部ドメインを DNS 解決しようとしたとき、**そのクエリをルールに基づいて許可・拒否・監視するファイアウォール**。

```
VPC 内のリソース
    │
    │ DNS クエリ（悪意あるドメインへ）
    ▼
Route 53 Resolver
    │
    │ DNS Firewall が検査
    ├── ルールにマッチ → BLOCK（NXDOMAIN か独自 IP を返す）
    └── マッチしない  → 通常通り解決
```

Network Firewall や WAF がパケット・HTTP レベルを見るのに対し、DNS Firewall は**名前解決の段階で**介入する。ドメインが IP に変わる前に止められるのがポイント。

---

## 何ができるか

### ドメインリストとルール

**ドメインリスト**にブロックまたは許可したいドメインを登録し、それを使って**ルール**を作る。

```
ドメインリスト（例）
  malware.example.com
  *.c2-server.net        ← ワイルドカード対応
  suspicious-domain.io

ルール
  ドメインリスト: 上記
  アクション: BLOCK
  応答: NXDOMAIN（ドメインが存在しないように見せる）
```

### AWS マネージドドメインリスト

自分でドメインリストを作る以外に、**AWS が管理するドメインリスト**を使える。

| リスト名 | 内容 |
|---|---|
| AWSManagedDomainsMalwareDomainList | マルウェアが使うことで知られているドメイン |
| AWSManagedDomainsBotnetCommandandControl | ボットネットの C2 ドメイン |
| AWSManagedDomainsAggregateThreatList | 上記を含む脅威インテリジェンスの集合 |

自前でブラックリストを管理しなくても、AWS が継続的に更新するリストをそのまま使える。

### アクションの種類

| アクション | 動作 |
|---|---|
| ALLOW | クエリを通す（ホワイトリスト用途） |
| BLOCK | クエリを遮断。NXDOMAIN か指定 IP を返す |
| ALERT | 遮断せず CloudWatch Logs にログだけ記録 |

**ALERT モード**が使いやすい。最初はブロックせず監視だけして、実際にどんなドメインが引かれているか把握してからブロックに切り替えることができる。

---

## 典型的な使い方

### パターン1：既知の悪意あるドメインをブロック

AWS マネージドリストをそのまま適用するだけで、主要な C2 ドメインやマルウェア配布ドメインへの DNS 解決を止められる。設定コストが低いわりに効果がある。

```
ルールグループ
  ルール1: AWSManagedDomainsMalwareDomainList → BLOCK (NXDOMAIN)
  ルール2: AWSManagedDomainsBotnetCommandandControl → BLOCK (NXDOMAIN)
```

### パターン2：許可リスト方式（ホワイトリスト）

業務で使うドメインだけを明示的に許可し、それ以外をすべてブロックする。制御は強いが運用コストが高い。Lambda やコンテナが外部 API を呼ぶ環境では向いていない場合もある。

```
ルールグループ（優先度順に評価）
  ルール1: 許可ドメインリスト → ALLOW（優先度: 高）
  ルール2: * → BLOCK（優先度: 低、デフォルト拒否）
```

### パターン3：まず ALERT で実態を把握してからブロック

既存の VPC にいきなりブロックルールを入れると業務影響が出るリスクがある。最初は ALERT モードで全クエリを記録し、問題なさそうなドメインを確認した上でブロックに切り替える。

---

## Network Firewall との違い

| 比較軸 | DNS Firewall | Network Firewall |
|---|---|---|
| 検査レイヤー | DNS（L7 の名前解決） | L4〜L7（パケット・HTTP） |
| 主な用途 | 不審ドメインへの通信を名前解決で止める | ポート・プロトコル・URLパターンでフィルタ |
| 設定コスト | 低い | 高い（ルート設定が必要） |
| DNS トンネリング検知 | 限定的（ドメイン単位） | より詳細な検査が可能 |

DNS Firewall だけでは Network Firewall の代わりにはならない。「既知の悪意あるドメインへの通信をコストをかけずに止めたい」という用途に適している。両方を組み合わせて使うのが理想。

---

## 設定の注意点

### フェイルオープンとフェイルクローズ

DNS Firewall サービス自体が応答できない状態になったとき、VPC からの DNS クエリをどうするかを選択できる。

- **フェイルオープン**（デフォルト）：DNS Firewall が利用不能でも DNS クエリを通す。可用性を優先
- **フェイルクローズ**：DNS Firewall が利用不能なら DNS クエリをすべて失敗させる。セキュリティを優先

本番環境でフェイルクローズにすると、DNS Firewall の障害が VPC 全体の名前解決障害につながる。リスクを理解した上で選択する。

### ログの出力先

クエリログは Route 53 Resolver のクエリログ設定とは別に、DNS Firewall のルールグループ単位でも記録される。CloudWatch Logs または S3 に出力可能。ALERT モードで使う場合は必ずログ出力を有効にする。

---

## いつ導入を検討するか

「AWS マネージドリストを ALERT モードで有効化する」だけなら設定コストはほぼゼロで、既知の C2 ドメインへのクエリを可視化できる。まず ALERT で入れておき、怪しいドメインへのクエリが記録されるようにしておくことをすすめる。

ブロックに踏み切るタイミングは、「ALERT ログを一定期間確認して業務ドメインへの誤検知がないことを確認してから」が現実的。

---

## 参考

- [Route 53 Resolver DNS Firewall - AWS 公式ドキュメント](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall.html)
- [AWS マネージドドメインリスト](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall-managed-domain-lists.html)
- [DNS Firewall と Network Firewall の使い分け（AWS ブログ）](https://aws.amazon.com/jp/blogs/networking-and-content-delivery/integrate-aws-network-firewall-with-aws-route-53-resolver-dns-firewall/)
