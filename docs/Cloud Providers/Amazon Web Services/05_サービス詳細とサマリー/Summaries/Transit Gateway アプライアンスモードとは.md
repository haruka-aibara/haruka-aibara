<!-- Space: harukaaibarapublic -->
<!-- Parent: Summaries -->
<!-- Title: Transit Gateway アプライアンスモードとは -->

# Transit Gateway アプライアンスモードとは

複数 VPC を Transit Gateway で接続し、ファイアウォールアプライアンス（Palo Alto、Fortinet など）を経由させる構成を組もうとしたとき、**通信が断続的に切れる・セッションが壊れる**という問題が起きることがある。アプライアンスモードはこれを解決するための設定だ。

## 何が起きているか

Transit Gateway は内部で複数の Availability Zone をまたいでトラフィックを転送する。デフォルトでは、**送り方向と返り方向のパケットが別々の AZ を通ることがある**。

```
送信: VPC A (AZ-a) → TGW → Firewall VPC (AZ-a) → 外部
返信: 外部 → TGW → Firewall VPC (AZ-b) → VPC A (AZ-a)  ← 別 AZ を経由
```

ステートフルなファイアウォール・NAT・ロードバランサーは、**行きと返りが同じインスタンスを通ること**を前提に動いている。AZ を跨いでしまうと、ファイアウォールが「このセッションの往路を知らない」と判断してパケットをドロップする。

## アプライアンスモードの動作

Transit Gateway の VPC アタッチメントに `ApplianceModeSupport: enable` を設定すると、TGW は **フローハッシュ（送信元 IP・宛先 IP・プロトコル・ポート）を見て同一セッションのパケットを常に同じ AZ に固定する**。

```
送信: VPC A (AZ-a) → TGW → Firewall VPC (AZ-a)
返信: 外部 → TGW → Firewall VPC (AZ-a)  ← 同じ AZ に固定される
```

これでファイアウォールが行きと返りの両パケットを見られるようになる。

## 設定方法

アプライアンスモードは **TGW アタッチメント単位**で有効にする。アプライアンス（ファイアウォール）が置かれている VPC のアタッチメントに設定する。

```bash
# アタッチメント作成時に有効化
aws ec2 create-transit-gateway-vpc-attachment \
  --transit-gateway-id tgw-xxxxxxxxxxxxxxxxx \
  --vpc-id vpc-xxxxxxxxxxxxxxxxx \
  --subnet-ids subnet-xxxxxxxxxxxxxxxxx subnet-yyyyyyyyyyyyyyyyy \
  --options ApplianceModeSupport=enable

# 既存アタッチメントを変更
aws ec2 modify-transit-gateway-vpc-attachment \
  --transit-gateway-attachment-id tgw-attach-xxxxxxxxxxxxxxxxx \
  --options ApplianceModeSupport=enable
```

コンソールでは VPC アタッチメントの「アプライアンスモードのサポート」を「有効化」にする。

## どの VPC のアタッチメントに設定するか

**アプライアンスが置かれている VPC のアタッチメントにのみ設定する**。送受信側のワークロード VPC には設定不要。

```
[Workload VPC A] ──アタッチメント（設定不要）──┐
                                               ├── TGW ── [Firewall VPC]──アタッチメント（enable）
[Workload VPC B] ──アタッチメント（設定不要）──┘
```

## アプライアンスモードが必要な構成

- **ステートフルファイアウォール（IDS/IPS含む）** を挟む VPC 間通信
- **NAT インスタンス**（NAT Gateway ではなく EC2 で NAT を実装している場合）
- **Network Load Balancer のターゲットがファイアウォールアプライアンス**の構成

逆に、**ステートレスな処理**（単純なルーティングのみ）であれば不要。

## AWS Network Firewall との組み合わせ

AWS Network Firewall もステートフル検査を行うため、アプライアンスモードが必要になる構成がある。ただし、Network Firewall エンドポイントは AZ ごとに独立したエンドポイントを持ち、TGW のルートテーブルで AZ ごとに次ホップを制御する設計が推奨されている。この場合もアプライアンスモードを有効にしてフロー固定を保証する。

```bash
# 設定確認
aws ec2 describe-transit-gateway-vpc-attachments \
  --transit-gateway-attachment-ids tgw-attach-xxxxxxxxxxxxxxxxx \
  --query 'TransitGatewayVpcAttachments[*].Options.ApplianceModeSupport'
```

## 参考

- [Appliance in a shared services VPC - AWS Transit Gateway](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-appliance-scenario.html)
- [Centralized inspection architecture with AWS Gateway Load Balancer and AWS Transit Gateway](https://aws.amazon.com/blogs/networking-and-content-delivery/centralized-inspection-architecture-with-aws-gateway-load-balancer-and-aws-transit-gateway/)
- [Transit Gateway - Appliance mode support](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-vpc-attachments.html#tgw-vpc-attachments-mode)
