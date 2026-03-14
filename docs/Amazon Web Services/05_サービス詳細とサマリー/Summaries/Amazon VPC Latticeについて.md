<!-- Space: harukaaibarapublic -->
<!-- Parent: サービス詳細とサマリー -->
<!-- Title: Amazon VPC Latticeについて -->

# Amazon VPC Lattice について

## どういうときに必要になるか

チームが増えてサービスが分かれてくると、こういう状況が起きる。

- 決済サービス（VPC-A）が注文サービス（VPC-B）を呼び出したい
- 注文サービスは別のAWSアカウントで動いている
- さらに在庫サービスは Lambda、ユーザー認証は ECS と、コンピューティングもバラバラ

この状況をVPC Peeringで解決しようとすると、VPCの数が増えるにつれてペアリングの数が爆発する（N×(N-1)/2）。Transit Gatewayを使えばハブになるが、IPアドレスが重複しているVPCは繋げない。そもそも「誰がどのサービスを呼んでいいか」というアクセス制御はネットワーク層ではなく、別途アプリ側で管理するしかなくなる。

**VPC Lattice はこの「マルチVPC・マルチアカウント環境でのサービス間通信」をまるごと引き受けるサービスだ。**

## VPC Lattice とは

フルマネージドのアプリケーションネットワーキングサービス。サービス間の接続・セキュリティ・モニタリングを一元管理する。

IPアドレスのCIDRが重複していても問題なく通信できる点が Transit Gateway との大きな違いのひとつ。

## 主要コンポーネント

### Service（サービス）

VPC Lattice における「呼び出す側から見えるエンドポイント」。背後は EC2 / ECS / EKS / Fargate / Lambda のいずれでも構わない。

Serviceは以下の要素で構成される：

- **Target Group**: 実際のサーバー群（EC2インスタンス、Lambda、ALBなど）
- **Listener**: 受け付けるプロトコルとポート（HTTP/HTTPS/TCP）
- **Rule**: パスやヘッダーに基づいてトラフィックをどのTarget Groupに流すかのルール

### Service Network（サービスネットワーク）

複数のServiceをまとめる論理的な境界。「このService Networkに参加しているVPCからは、このService Networkに登録されたサービスに通信できる」という仕組み。

VPCとService Networkを紐付ける（VPC Association）ことで、そのVPCのリソースが対象サービスを呼べるようになる。

### Resource / Resource Gateway / Resource Configuration

HTTPサービス以外のリソース（RDSデータベース、IPアドレス、ドメイン名など）を扱うための仕組み。TCPプロトコルで接続する。

- **Resource Gateway**: リソースが存在するVPCへの入口
- **Resource Configuration**: リソースをVPC Lattice上で扱える形にラップしたオブジェクト

たとえば「別アカウントのRDSに対してVPC Peeringなしでアクセスしたい」という場面でResource Configurationを使う。

### Auth Policy（認証・認可ポリシー）

IAMポリシーに似た構文で、「誰がこのサービスを呼べるか」を定義する。

- **Service Network レベル**: ネットワーク全体への粗いアクセス制御
- **Service レベル**: 個別サービスへの細かいアクセス制御

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/order-service-role"
      },
      "Action": "vpc-lattice-svcs:Invoke",
      "Resource": "*"
    }
  ]
}
```

この例では `order-service-role` を持つリソースからのみ呼び出しを許可している。

## 既存手法との比較

| 課題 | VPC Peering | Transit Gateway | VPC Lattice |
|------|-------------|-----------------|-------------|
| CIDR重複 | 不可 | 不可 | **対応** |
| マルチアカウント | 設定複雑 | 対応 | **対応（AWS RAM経由）** |
| アクセス制御 | セキュリティグループのみ | セキュリティグループのみ | **IAMポリシーで細粒度制御** |
| L7ルーティング | 不可 | 不可 | **対応（パス・ヘッダーベース）** |
| スケーラビリティ | 接続数が爆発 | 管理しやすい | **フルマネージド** |

## どういう構成で使うか

```
[VPC A: 注文サービス]
    ↓ (VPC Association)
[Service Network: "prod-network"]
    ↑ (Service Association)
[VPC B: 決済サービス]  ← 別アカウント・CIDR重複でもOK
[Lambda: 通知サービス] ← コンピューティングが違ってもOK
[RDS: 商品DB]         ← Resource Configurationで接続
```

`prod-network` に参加したVPCのリソースは、登録されたサービスをDNS名で呼び出せる。ネットワーク管理者がService Networkを作り、開発チームが自分のサービスを登録するという役割分担が自然にできる。

## 既存の構成と組み合わせる際の注意

- **VPC Lattice はL4/L7サービスが前提**。純粋なL3（IP-to-IP）の疎通が必要な場面は Transit Gateway や VPC Peering が引き続き適切
- **既存のALBと共存可能**。ALBをTarget Groupに登録してVPC Latticeの前段に置くことができる
- **Kubernetes（EKS）との統合**：AWS Gateway API Controller を使うと、Kubernetes の Gateway API リソースとして VPC Lattice を操作できる

## 参考

- [Amazon VPC Lattice とは - AWS ドキュメント](https://docs.aws.amazon.com/vpc-lattice/latest/ug/what-is-vpc-lattice.html)
- [Amazon VPC Lattice の機能](https://aws.amazon.com/jp/vpc/lattice/features/)
- [複数のAWSアカウントにまたがる共有サービスへのアクセスを合理化してセキュリティで保護する](https://aws.amazon.com/jp/blogs/news/streamline-and-secure-access-to-shared-services-and-resources-with-amazon-vpc-lattice/)
- [VPC Lattice を使用して複数の AWS アカウントにまたがる TCP リソース接続を合理化してセキュリティで保護する](https://aws.amazon.com/blogs/networking-and-content-delivery/use-amazon-vpc-lattice-to-streamline-and-secure-tcp-resource-connectivity-across-multiple-aws-accounts/)
