# AWS Glue DPU (難易度レベル: 100)

## 概要
AWS GlueのDPU（Data Processing Unit）は、AWS Glueジョブの処理能力を測定する単位です。DPUは、AWS Glueがデータの抽出・変換・読み込み（ETL）処理を実行する際に使用するコンピューティングリソースの量を表します。DPUを理解することで、コスト効率的でパフォーマンスの良いデータ処理パイプラインを構築できます。

DPUを学ぶ意義：
- AWS Glueのコスト構造の理解
- パフォーマンスとコストの最適化
- リソース計画の効率化
- 大規模データ処理の設計

## 詳細

### DPUとは

#### 基本的な概念
DPU（Data Processing Unit）は、AWS Glueの処理能力を表す単位です。1つのDPUは以下のリソースを提供します：

- **4 vCPU**: 仮想CPUコア
- **16 GB メモリ**: 処理用のメモリ
- **64 GB ディスク**: 一時的なデータ保存用のディスク容量

#### DPUの特徴
- **サーバーレス**: インフラストラクチャの管理が不要
- **自動スケーリング**: 処理量に応じて自動的にスケール
- **従量課金**: 実際に使用したDPU時間分のみ課金
- **並列処理**: 複数のDPUを同時に使用可能

### DPUの計算方法

#### 基本的な計算
```python
# DPU時間の計算例
# 処理時間: 10分
# 使用DPU数: 2
# DPU時間 = 10分 × 2DPU = 20 DPU分

# コスト計算（米国東部リージョンの場合）
# 1 DPU時間あたり $0.44
# コスト = 20 DPU分 × ($0.44 / 60分) = $0.147
```

#### 実際の使用例
```python
# 小規模なデータ処理（1-2 DPU）
# 処理時間: 5分
# 使用DPU: 1
# コスト: 5分 × 1DPU × ($0.44 / 60分) = $0.037

# 中規模なデータ処理（2-5 DPU）
# 処理時間: 15分
# 使用DPU: 3
# コスト: 15分 × 3DPU × ($0.44 / 60分) = $0.33

# 大規模なデータ処理（5-10 DPU）
# 処理時間: 30分
# 使用DPU: 8
# コスト: 30分 × 8DPU × ($0.44 / 60分) = $1.76
```

### DPUの設定方法

#### ジョブ作成時の設定
```python
# AWS Glueジョブの作成例
import boto3

glue_client = boto3.client('glue')

# 基本的なジョブ作成
response = glue_client.create_job(
    Name='my_etl_job',
    Role='AWSGlueServiceRole',
    Command={
        'Name': 'glueetl',
        'ScriptLocation': 's3://bucket-name/scripts/my_script.py'
    },
    MaxCapacity=2,  # 最大2 DPUを使用
    Timeout=60,     # 60分でタイムアウト
    GlueVersion='3.0'
)
```

#### 動的DPU設定
```python
# 動的DPU設定の例
response = glue_client.create_job(
    Name='dynamic_dpu_job',
    Role='AWSGlueServiceRole',
    Command={
        'Name': 'glueetl',
        'ScriptLocation': 's3://bucket-name/scripts/dynamic_script.py'
    },
    MaxCapacity=5,      # 最大5 DPU
    WorkerType='G.1X',  # ワーカータイプの指定
    NumberOfWorkers=3,  # ワーカー数の指定
    Timeout=120
)
```

### DPUの最適化

#### データ量に応じた設定
```python
# データ量別の推奨DPU設定

# 小規模データ（1GB未満）
# 推奨DPU: 1-2
# 処理時間: 5-10分

# 中規模データ（1GB-10GB）
# 推奨DPU: 2-5
# 処理時間: 10-30分

# 大規模データ（10GB以上）
# 推奨DPU: 5-10
# 処理時間: 30分以上
```

#### 処理タイプ別の設定
```python
# 処理タイプ別のDPU設定例

# データ読み込み（Extract）
# 軽量な処理: 1-2 DPU
# 大容量ファイル: 3-5 DPU

# データ変換（Transform）
# 単純な変換: 2-3 DPU
# 複雑な変換: 4-8 DPU

# データ書き込み（Load）
# 単一ファイル出力: 1-2 DPU
# 複数ファイル出力: 2-4 DPU
```

### コスト最適化の実践

#### 効率的なDPU使用
```python
# コスト最適化のためのベストプラクティス

# 1. 適切なDPU数の設定
def calculate_optimal_dpu(data_size_gb, complexity='medium'):
    """
    データサイズと複雑度に基づいて最適なDPU数を計算
    """
    base_dpu = max(1, data_size_gb // 2)  # 2GBあたり1DPU
    
    if complexity == 'low':
        return min(base_dpu, 2)
    elif complexity == 'medium':
        return min(base_dpu, 5)
    else:  # high
        return min(base_dpu, 10)

# 使用例
optimal_dpu = calculate_optimal_dpu(8, 'medium')  # 4 DPU
```

#### 処理時間の最適化
```python
# 処理時間を短縮するための設定

# パーティション数の最適化
def optimize_partitions(dataframe, target_partitions=10):
    """
    データフレームのパーティション数を最適化
    """
    current_partitions = dataframe.rdd.getNumPartitions()
    
    if current_partitions > target_partitions * 2:
        return dataframe.coalesce(target_partitions)
    elif current_partitions < target_partitions // 2:
        return dataframe.repartition(target_partitions)
    else:
        return dataframe

# キャッシュの活用
def optimize_with_cache(dataframe):
    """
    頻繁に使用するデータフレームをキャッシュ
    """
    dataframe.cache()
    return dataframe
```

### 実際の使用例

#### 小規模ETLジョブ
```python
# 小規模なデータ処理の例
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# ジョブパラメータの取得
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

# Glueコンテキストの初期化
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# データの読み込み（1-2 DPUで十分）
customers = glueContext.create_dynamic_frame.from_catalog(
    database="my_database",
    table_name="customers"
)

# 簡単な変換処理
cleaned_customers = customers.filter(
    lambda x: x["age"] > 0 and x["age"] < 120
)

# データの書き込み
glueContext.write_dynamic_frame.from_catalog(
    frame=cleaned_customers,
    database="my_database",
    table_name="cleaned_customers"
)

job.commit()
```

#### 中規模ETLジョブ
```python
# 中規模なデータ処理の例
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# 複数のデータソースの読み込み（2-5 DPU推奨）
orders = glueContext.create_dynamic_frame.from_catalog(
    database="my_database",
    table_name="orders"
)

products = glueContext.create_dynamic_frame.from_catalog(
    database="my_database",
    table_name="products"
)

# データの結合と変換
orders_df = orders.toDF()
products_df = products.toDF()

# 結合処理
joined_data = orders_df.join(products_df, "product_id", "inner")

# 集計処理
summary_data = joined_data.groupBy("product_category").agg(
    {"order_amount": "sum", "order_id": "count"}
)

# 結果の保存
summary_dynamic_frame = DynamicFrame.fromDF(summary_data, glueContext, "summary")
glueContext.write_dynamic_frame.from_catalog(
    frame=summary_dynamic_frame,
    database="my_database",
    table_name="sales_summary"
)

job.commit()
```

### モニタリングと分析

#### DPU使用量の監視
```python
# CloudWatchを使用したDPU使用量の監視
import boto3
from datetime import datetime, timedelta

cloudwatch = boto3.client('cloudwatch')

def get_dpu_usage(job_name, start_time, end_time):
    """
    ジョブのDPU使用量を取得
    """
    response = cloudwatch.get_metric_statistics(
        Namespace='AWS/Glue',
        MetricName='DPU',
        Dimensions=[
            {
                'Name': 'JobName',
                'Value': job_name
            }
        ],
        StartTime=start_time,
        EndTime=end_time,
        Period=300,  # 5分間隔
        Statistics=['Average', 'Maximum']
    )
    return response

# 使用例
end_time = datetime.utcnow()
start_time = end_time - timedelta(hours=1)
dpu_usage = get_dpu_usage('my_etl_job', start_time, end_time)
```

#### コスト分析
```python
# コスト分析のための関数
def calculate_job_cost(dpu_minutes, region='us-east-1'):
    """
    ジョブのコストを計算
    """
    # リージョン別のDPU単価（USD/DPU時間）
    dpu_prices = {
        'us-east-1': 0.44,
        'us-west-2': 0.44,
        'eu-west-1': 0.48,
        'ap-northeast-1': 0.50
    }
    
    price_per_hour = dpu_prices.get(region, 0.44)
    price_per_minute = price_per_hour / 60
    
    total_cost = dpu_minutes * price_per_minute
    return total_cost

# 使用例
job_cost = calculate_job_cost(120, 'us-east-1')  # 2時間分
print(f"ジョブコスト: ${job_cost:.2f}")
```

## まとめ

### 学んだことの振り返り
- **DPU**: AWS Glueの処理能力を表す単位
- **リソース構成**: 4 vCPU、16 GB メモリ、64 GB ディスク
- **コスト計算**: DPU時間 × 単価による従量課金
- **最適化**: データ量と処理複雑度に応じた適切な設定
- **モニタリング**: CloudWatchを使用した使用量監視

### 次のステップへの提案
1. **AWS Glue ETLジョブ**: 実際のETLパイプラインの構築
2. **Glue DataBrew**: 視覚的なデータ準備とDPU最適化
3. **Glue Studio**: ノーコードETL開発環境
4. **パフォーマンスチューニング**: より高度な最適化手法
5. **コスト管理**: 予算設定とアラートの設定
6. **自動化**: スケジュール実行とワークフロー管理

AWS GlueのDPUを理解することで、コスト効率的でパフォーマンスの良いデータ処理システムを構築できます。基本的な概念を理解した後は、実際のプロジェクトで活用することで、より実践的なスキルを身につけることができます。 
