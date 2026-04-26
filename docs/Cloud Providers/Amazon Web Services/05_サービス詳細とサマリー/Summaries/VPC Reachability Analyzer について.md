<!-- Space: harukaaibarapublic -->
<!-- Parent: サービス詳細とサマリー -->
<!-- Title: VPC Reachability Analyzer について -->

# VPC Reachability Analyzer について

## こんなとき困る

セキュリティグループを変更した、ルートテーブルを追加した、Transit Gateway を経由するように構成を変えた——その後、「なぜかつながらない」になる。
あるいは逆に、「本当にここはブロックされているのか確認したい」という場面。

パケットがどこで止まっているかを調べようとすると、セキュリティグループ・NACL・ルートテーブル・ENI の設定を一個ずつ手で追うことになる。構成が複雑になるほどどこが悪いか特定するのに時間がかかる。

VPC Reachability Analyzer はその「どこで止まっているか」を AWS が自動で特定してくれるツール。

## 何をするツールか

送信元と送信先のリソースを指定してパスを定義し、分析を実行する。

- **到達可能な場合**：送信元から送信先までのホップバイホップの経路を表示する
- **到達不可能な場合**：どのコンポーネントがブロックしているかをコード付きで示す

実際にパケットを送るわけではない。**設定情報（コントロールプレーン）を静的に解析する**ツール。なので通信を止めずに実行でき、パケットキャプチャも不要。

### 対応リソース（分析対象）

- EC2 インスタンス、ネットワークインターフェース（ENI）
- インターネットゲートウェイ、NAT ゲートウェイ
- Transit Gateway、Transit Gateway アタッチメント
- VPC ピアリング接続、VPN ゲートウェイ
- VPC エンドポイント、VPC エンドポイントサービス
- ロードバランサー

## 使い方の流れ

### コンソールの場合

1. VPC コンソール → 「Reachability Analyzer」→「パスの作成」
2. 送信元・送信先リソース、プロトコル、ポートを指定
3. 「パスの分析」を実行
4. 結果を確認（通常 1〜2 分で完了）

### CLI の場合

**パスを作成する**

```bash
aws ec2 create-network-insights-path \
  --source igw-0797cccdc9d73b0e5 \
  --destination i-0495d385ad28331c7 \
  --protocol TCP \
  --filter-at-source file://source-filter.json
```

```json
// source-filter.json
{
  "DestinationPortRange": {
    "FromPort": 22,
    "ToPort": 22
  }
}
```

**分析を実行する**

```bash
aws ec2 start-network-insights-analysis \
  --network-insights-path-id nip-0abc123def456789
```

**結果を取得する**

```bash
aws ec2 describe-network-insights-analyses \
  --network-insights-analysis-ids nia-0abc123def456789
```

到達不可能な場合は `NetworkPathFound: false` になり、`ExplanationCode` に理由が入る。

| コード例 | 意味 |
|---|---|
| `ENI_SG_RULES_MISMATCH` | セキュリティグループのルールがトラフィックを許可していない |
| `SUBNET_ACL_RESTRICTION` | NACL がブロックしている |
| `NO_ROUTE_TO_DESTINATION` | ルートテーブルに宛先へのルートがない |
| `ELB_LISTENER_PORT_RESTRICTION` | ロードバランサーのリスナー設定が合っていない |

## CI/CD に組み込む使い方

ネットワーク構成変更後の回帰テストとして使える。「この EC2 から RDS に到達できること」「このサブネットからインターネットに直接出られないこと」をコードで定義し、デプロイ後に自動検証する。

```bash
# パスを分析して到達可能かどうかを確認する例
ANALYSIS_ID=$(aws ec2 start-network-insights-analysis \
  --network-insights-path-id $PATH_ID \
  --query 'NetworkInsightsAnalysis.NetworkInsightsAnalysisId' \
  --output text)

# 完了を待つ
aws ec2 wait network-insights-analysis-exists \
  --network-insights-analysis-ids $ANALYSIS_ID

# 結果を確認
REACHABLE=$(aws ec2 describe-network-insights-analyses \
  --network-insights-analysis-ids $ANALYSIS_ID \
  --query 'NetworkInsightsAnalyses[0].NetworkPathFound' \
  --output text)

if [ "$REACHABLE" = "True" ]; then
  echo "PASS: 到達可能"
else
  echo "FAIL: 到達不可能"
  exit 1
fi
```

構成変更のたびに手で確認するのではなく、「意図した接続性が保たれているか」を自動で保証する仕組みを作れる。

## Network Access Analyzer との違い

混同しやすいが目的が異なる。

| ツール | 目的 |
|---|---|
| **Reachability Analyzer** | 「A から B へ通信できるか」という特定のパスを検証する |
| **Network Access Analyzer** | 「このリソースにアクセスできる経路が他にないか」をネットワーク全体から洗い出す |

意図しないアクセス経路を探したいなら Network Access Analyzer、特定の疎通を確認・デバッグしたいなら Reachability Analyzer という使い分け。

## 料金

分析を 1 回実行するごとに課金される（パスの作成・保存は無料）。
料金は VPC Pricing の「Network Analysis」タブで確認できる。

## 参考

- [What is Reachability Analyzer? - Amazon VPC](https://docs.aws.amazon.com/vpc/latest/reachability/what-is-reachability-analyzer.html)
- [Getting started with Reachability Analyzer using the AWS CLI](https://docs.aws.amazon.com/vpc/latest/reachability/getting-started-cli.html)
- [Reachability Analyzer explanation codes](https://docs.aws.amazon.com/vpc/latest/reachability/explanation-codes.html)
- [Amazon VPC Pricing - Network Analysis](https://aws.amazon.com/vpc/pricing/)
