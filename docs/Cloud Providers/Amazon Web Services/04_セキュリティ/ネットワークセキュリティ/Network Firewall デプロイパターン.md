<!-- Space: harukaaibarapublic -->
<!-- Parent: ネットワークセキュリティ -->
<!-- Title: AWS Network Firewall デプロイパターン：分散 vs 集約 -->

# AWS Network Firewall デプロイパターン：分散 vs 集約

## なぜパターン選択で迷うのか

AWS Network Firewall を導入しようとすると、まず問われるのが「どこに置くか」だ。VPC ごとに独立して置く（分散）か、中央の検査 VPC に集めて TGW で通す（集約）か。どちらを選ぶかによってコスト・管理負荷・ルーティング設計がまるで変わる。

「とりあえず集約の方がプロっぽい」で選ぶと、TGW の Appliance Mode を有効にし忘れて非対称ルーティングでハマる、というのが典型的な失敗パターン。選択基準を理解してから設計した方がいい。

---

## 3 つのデプロイモデル

### 1. 分散デプロイ（Distributed）

各 VPC に Network Firewall エンドポイントを配置する。

```
[Internet Gateway]
        ↓  (IGW ルートテーブル: dst=10.0.1.0/24 → Firewall Endpoint)
[Firewall Subnet] ← Network Firewall Endpoint
        ↓  (Firewall ルートテーブル: 0.0.0.0/0 → IGW)
[Application Subnet]
```

IGW に「戻り」のルートも書く必要がある（IGW ルートテーブルに Ingress Routing）。これが分散デプロイの独特な設定で、忘れると通信が非対称になる。

**向いている場面:**
- VPC 数が少ない（2〜5 程度）
- VPC ごとにポリシーを完全に分けたい
- Transit Gateway を使っていない、または使いたくない

**サブネット設計の注意点:**
- Firewall サブネットは /28 で十分（Firewall エンドポイントの実体は ENI 1 つ）
- AZ ごとに 1 サブネット作成する（AZ をまたぐとデータ転送コストとレイテンシが増える）

**コスト感:**
- Firewall Endpoint: 約 $0.395/時 × VPC 数 × AZ 数
- 3 VPC × 2 AZ = 6 エンドポイント → 月 $1,700 前後

---

### 2. 集約デプロイ（Centralized）

中央の Inspection VPC に Network Firewall を置き、すべてのトラフィックを Transit Gateway 経由で通す。

```
[Spoke VPC A] ──┐
[Spoke VPC B] ──┼──→ [TGW] ──→ [Inspection VPC]
[Spoke VPC C] ──┘              [Network Firewall]
                                       ↓
                              [Egress VPC / IGW]
```

**TGW Appliance Mode が必須。** Appliance Mode を有効にしないと、戻りのパケットが別の AZ のエンドポイントを通って非対称ルーティングになり、セッションがドロップする。TGW アタッチメントの設定で `ApplianceModeSupport: enable` を指定する。

**ルートテーブル設計（North-South の例）:**

| TGW ルートテーブル | 宛先 | ネクストホップ |
|---|---|---|
| Spoke 用 RT | 0.0.0.0/0 | Inspection VPC アタッチメント |
| Inspection 用 RT | 10.0.0.0/8 | Spoke VPC アタッチメント群 |

**向いている場面:**
- VPC が多い（10 以上）
- マルチアカウント構成（AWS Organizations + Firewall Manager で一元管理）
- East-West（VPC 間）トラフィックも検査したい
- コストを絞りたい（エンドポイント数を減らせる）

**コスト感:**
- Firewall Endpoint は Inspection VPC 内の AZ 数だけ（例: 2 AZ = 2 エンドポイント）
- TGW のアタッチメント料金・データ処理料金が追加される
- VPC が多いほど分散より圧倒的に安くなる

---

### 3. コンバインドデプロイ（Combined）

分散と集約を目的別に使い分ける。典型的なパターン：

- **North-South（インターネット向け）**: Inspection VPC に集約
- **East-West（VPC 間）**: TGW 経由で同じ Inspection VPC を通す
- **一部の VPC はセキュリティ要件が高いので個別に分散配置**

「すべてを 1 つのモデルで解決しようとしない」というのが、この選択肢の意義。設計は複雑になるが、大企業のマルチアカウント環境ではよく使われる。

---

## 分散 vs 集約 まとめ比較

| 観点 | 分散 | 集約 |
|---|---|---|
| コスト | VPC が増えるほど高い | TGW 料金が加わるが VPC 数が多いと安い |
| 管理負荷 | VPC ごとに設定が必要 | 中央管理（Firewall Manager と相性◎） |
| レイテンシ | 低い（TGW を経由しない） | TGW 分だけ増加（通常は数 ms 以下） |
| 障害影響 | 1 VPC に閉じる | Inspection VPC 障害で全体に影響 |
| East-West 検査 | 困難（VPC 間を TGW が通らないと検査できない） | 自然に実現できる |
| 設定の複雑さ | IGW Ingress Routing を忘れやすい | TGW Appliance Mode の見落としが多い |

---

## Gateway Load Balancer（GWLB）との違い

「集約デプロイ」という構成は GWLB でも実現できる。両者の違い：

| | Network Firewall | GWLB + サードパーティ Appliance |
|---|---|---|
| 運用 | AWS マネージド | Appliance の OS・パッチ管理が必要 |
| 機能 | ステートフル/ステートレス + Suricata ルール + TLS Inspection | ベンダー製品の全機能が使える |
| 選択基準 | AWS ネイティブで完結させたい | Palo Alto・Fortinet 等を既存で使っている |

既存のオンプレ環境で Palo Alto を使っていて、ポリシーを統一したい場合は GWLB + サードパーティが現実的。AWS ネイティブで新規に始めるなら Network Firewall の方がオペレーションコストが低い。

---

## AWS Firewall Manager との組み合わせ

集約デプロイと Firewall Manager を組み合わせると、Organizations 配下のすべてのアカウントに対してポリシーを自動適用できる。

```
AWS Organizations
└── Firewall Manager（管理アカウント）
    ├── Policy: すべての VPC に Network Firewall を自動デプロイ
    └── Policy: WAF ルールをすべての CloudFront に適用
```

**実務での使い方**: 新しいアカウントを Organizations に追加すると Firewall Manager が自動で Network Firewall エンドポイントを作成してくれる。「アカウントを作ったのにファイアウォールを設定し忘れた」を防げる。

---

## どのパターンを選ぶか

```
VPC が 5 以下で TGW 未使用
  → 分散デプロイ（シンプルさ優先）

VPC が多い or マルチアカウント
  → 集約デプロイ + Firewall Manager

East-West と North-South を別々に制御したい
  → コンバインド（設計の複雑さは上がる）

既存の商用 Appliance を使いたい
  → GWLB + サードパーティ製品
```

「集約の方がプロっぽい」は半分正しくて半分間違い。大規模な環境では集約が正解だが、小規模な環境で無理に集約すると TGW の設定ミスや複雑なルート設計で運用コストが上がるだけになる。

---

## コスト最適化のヒント

**ステートレスルールでトラフィックを絞る**: データ処理料金はステートフル検査の方が高い。「許可してよい既知のトラフィック（監視系の死活監視 ping 等）」はステートレスルールで先に通してしまい、ステートフル検査に渡すトラフィックを絞ると処理コストを下げられる。

**AZ をまたがないルーティングにする**: Network Firewall のエンドポイントと、そこにトラフィックを送るリソースが別 AZ にある場合、AZ 間データ転送料金が発生する。Firewall サブネットと Application サブネットを同じ AZ に配置し、AZ ごとに独立したルートテーブルを使う設計が推奨。

**AWS Managed Rule Groups を活用する**: 自前でゼロからルールを書かず、AWS が提供するマネージドルールグループ（脅威シグネチャ、ボット検知等）を有効化する。追加料金はかかるが、シグネチャのメンテナンスコストを削減できる。

---

## 参考

- [AWS Network Firewall デプロイメントモデル - AWS ドキュメント](https://docs.aws.amazon.com/network-firewall/latest/developerguide/deployment-models.html)
- [Deployment models for AWS Network Firewall - AWS Blog](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall/)
- [AWS Network Firewall – New Managed Firewall Service in VPC](https://aws.amazon.com/blogs/aws/aws-network-firewall-new-managed-firewall-service-in-vpc/)
- [Centralized inspection architecture with AWS Gateway Load Balancer and AWS Transit Gateway](https://aws.amazon.com/blogs/networking-and-content-delivery/centralized-inspection-architecture-with-aws-gateway-load-balancer-and-aws-transit-gateway/)
- [AWS Firewall Manager – Centrally Manage Firewall Rules](https://docs.aws.amazon.com/waf/latest/developerguide/fms-chapter.html)
