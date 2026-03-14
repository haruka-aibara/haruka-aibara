<!-- Space: harukaaibarapublic -->
<!-- Parent: Summaries -->
<!-- Title: API Gateway VPC Link について -->

# API Gateway VPC Link について

## どういうときに必要になるか

API Gateway はパブリックな AWS マネージドサービスで、デフォルトではインターネット経由でバックエンドにリクエストを転送する。

問題は、バックエンドが VPC のプライベートサブネットにある場合だ。ECS Fargate や EC2 のアプリケーションをプライベートサブネットに置くのはセキュリティ上の常識だが、API Gateway からアクセスするために ALB や NLB をパブリックに出してしまうと、インターネットからの攻撃面が広がる。

**VPC Link を使うと、API Gateway が VPC 内のリソースにプライベートネットワーク経由で直接アクセスできるようになる。** バックエンドの ALB/NLB をプライベートに保ったまま、API Gateway からルーティングを通せる。

```
インターネット
     ↓
API Gateway（パブリック）
     ↓（VPC Link 経由・プライベート）
NLB または ALB（プライベートサブネット）
     ↓
ECS / EC2（プライベートサブネット）
```

## 2種類の VPC Link

API Gateway には REST API（v1）と HTTP API（v2）があり、対応する VPC Link が異なる。

| | REST API 用（v1） | HTTP API 用（v2） |
|---|---|---|
| 接続先 | NLB のみ | ALB、NLB、Cloud Map |
| セキュリティグループ | なし（NLB 側で制御） | VPC Link 自体に SG を設定 |
| 新規採用の推奨 | - | こちらを推奨 |

REST API 用の VPC Link は NLB しか使えない。ALB を直接つなぎたい場合は HTTP API に切り替えるか、ALB の前に NLB を挟む構成になる。

## 設定の流れ（HTTP API + ALB の例）

### 1. ALB をプライベートサブネットに作成

ALB は `internal` スキームで作成する。パブリックサブネットに出す必要はない。

### 2. VPC Link を作成

```
VPC Link（HTTP API 用）
├── VPC: バックエンドが動いている VPC
├── サブネット: プライベートサブネット（複数 AZ 推奨）
└── セキュリティグループ: ALB への 443 または 80 を許可
```

VPC Link 作成後、ステータスが `PENDING → AVAILABLE` になるまで数分かかる。

### 3. ALB のセキュリティグループ更新

ALB の inbound に「VPC Link のセキュリティグループからのアクセス」を許可するルールを追加する。

### 4. HTTP API のインテグレーション設定

```
インテグレーションタイプ: Private resource
VPC Link: 作成した VPC Link
ターゲット: ALB の ARN（またはリスナーの ARN）
HTTP メソッド: ANY（またはルートに合わせて設定）
```

## ハマりポイント

**REST API で ALB を使いたい場合**：REST API 用 VPC Link は NLB のみ対応。ALB を使いたいなら HTTP API に切り替えるのが現実的。

**NLB のセキュリティグループ**：NLB 自体はセキュリティグループを持たない（REST API 用 VPC Link 経由の場合）。バックエンド EC2/ECS のセキュリティグループで NLB のプライベート IP からのアクセスを許可する必要がある。NLB の IP は固定なので、サブネット CIDR で許可する運用が多い。

**VPC Link の作成時間**：作成してすぐに使えるわけではない。`AVAILABLE` になるまで待つ必要がある。Terraform でデプロイする場合は `depends_on` や `wait` で制御する。

**HTTP API 用 VPC Link の SG 設定漏れ**：HTTP API 用 VPC Link にはセキュリティグループを設定する。この SG から ALB への通信を許可し、さらに ALB の SG でその VPC Link の SG からの inbound を許可する。設定が片方だけだと疎通しない。

## 参考

- [AWS - VPC リンクを使用してプライベートリソースにアクセスする（HTTP API）](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/http-api-vpc-links.html)
- [AWS - REST API の VPC リンクを設定する](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/set-up-private-integration.html)
- [AWS - HTTP API と REST API の選択](https://docs.aws.amazon.com/ja_jp/apigateway/latest/developerguide/http-api-vs-rest.html)
