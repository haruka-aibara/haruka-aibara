# AWS Glue DataFrame (難易度レベル: 100)

## 概要
AWS GlueのDataFrameは、AWSが提供するサーバーレスデータ統合サービス「AWS Glue」において、データの処理・変換・分析を行うための主要なデータ構造です。Apache SparkのDataFrameをベースにしており、大規模データの効率的な処理を可能にします。

AWS Glue DataFrameを学ぶ意義：
- サーバーレスデータ処理の理解
- ETL（Extract, Transform, Load）パイプラインの構築
- 大規模データの効率的な処理
- AWSエコシステムでのデータ統合

## 詳細

### AWS Glue DataFrameとは

#### 基本的な概念
AWS Glue DataFrameは、構造化データを扱うための2次元の表形式データ構造です。以下の特徴があります：

- **スキーマ付きデータ**: 列名とデータ型が定義された構造化データ
- **分散処理**: 大規模データを複数のノードで並列処理
- **遅延評価**: 実際の処理はアクションが実行されるまで遅延
- **最適化**: Sparkエンジンによる自動的な最適化

#### AWS Glueの役割
AWS Glueは、以下の機能を提供します：

- **データカタログ**: メタデータの中央管理
- **ETLジョブ**: データの抽出・変換・読み込み
- **データ品質**: データの検証とクリーニング
- **スケジューリング**: 定期的なデータ処理の自動化

### DataFrameの基本操作

#### DataFrameの作成
```python
# AWS Glueコンテキストの取得
from awsglue.context import GlueContext
from pyspark.context import SparkContext

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

# 基本的なDataFrameの作成
data = [
    ("田中太郎", 30, "東京"),
    ("佐藤花子", 25, "大阪"),
    ("鈴木一郎", 35, "名古屋")
]

columns = ["name", "age", "city"]
df = spark.createDataFrame(data, columns)

# データの表示
df.show()
```

#### データの読み込み
```python
# CSVファイルの読み込み
df_csv = spark.read.csv("s3://bucket-name/data.csv", header=True, inferSchema=True)

# JSONファイルの読み込み
df_json = spark.read.json("s3://bucket-name/data.json")

# Parquetファイルの読み込み
df_parquet = spark.read.parquet("s3://bucket-name/data.parquet")

# AWS Glueカタログからの読み込み
df_catalog = glueContext.create_dynamic_frame.from_catalog(
    database="my_database",
    table_name="my_table"
).toDF()
```

#### 基本的なデータ操作
```python
# データの表示
df.show()  # 最初の20行を表示
df.show(5)  # 最初の5行を表示
df.printSchema()  # スキーマの表示

# 基本的な統計情報
df.describe().show()

# 列の選択
df.select("name", "age").show()

# 条件付きフィルタリング
df.filter(df.age > 30).show()

# ソート
df.orderBy("age", ascending=False).show()

# 重複の除去
df.dropDuplicates(["name"]).show()
```

### データ変換と処理

#### 列の操作
```python
# 新しい列の追加
from pyspark.sql.functions import col, when

df_with_status = df.withColumn(
    "status",
    when(col("age") >= 30, "senior").otherwise("junior")
)

# 列名の変更
df_renamed = df.withColumnRenamed("name", "full_name")

# 列の削除
df_dropped = df.drop("city")

# 条件付きの値設定
df_updated = df.withColumn(
    "age_group",
    when(col("age") < 25, "young")
    .when(col("age") < 35, "middle")
    .otherwise("senior")
)
```

#### 集計操作
```python
from pyspark.sql.functions import count, avg, sum, max, min

# 基本的な集計
df.groupBy("city").count().show()

# 複数の集計関数
df.groupBy("city").agg(
    count("*").alias("total_count"),
    avg("age").alias("avg_age"),
    max("age").alias("max_age")
).show()

# ウィンドウ関数
from pyspark.sql.window import Window
from pyspark.sql.functions import row_number, rank

window_spec = Window.partitionBy("city").orderBy("age")

df_with_rank = df.withColumn(
    "age_rank",
    rank().over(window_spec)
)
```

#### データの結合
```python
# 別のDataFrameの作成
data2 = [
    ("田中太郎", "エンジニア"),
    ("佐藤花子", "デザイナー"),
    ("高橋美咲", "マネージャー")
]

df2 = spark.createDataFrame(data2, ["name", "job"])

# 内部結合
df_joined = df.join(df2, "name", "inner")

# 左外部結合
df_left_joined = df.join(df2, "name", "left")

# 複数条件での結合
df_complex_join = df.join(df2, ["name", "city"], "inner")
```

### AWS Glue特有の機能

#### DynamicFrameの活用
```python
# DynamicFrameの作成
dynamic_frame = glueContext.create_dynamic_frame.from_catalog(
    database="my_database",
    table_name="my_table"
)

# DynamicFrameからDataFrameへの変換
df = dynamic_frame.toDF()

# DataFrameからDynamicFrameへの変換
dynamic_frame = DynamicFrame.fromDF(df, glueContext, "my_dynamic_frame")

# DynamicFrameの操作
# スキーマの変更
dynamic_frame_resolved = dynamic_frame.resolveChoice(
    specs=[("age", "cast:int")]
)

# 欠損値の処理
dynamic_frame_cleaned = dynamic_frame.apply_mapping([
    ("name", "string", "full_name", "string"),
    ("age", "int", "age", "int"),
    ("city", "string", "location", "string")
])
```

#### データカタログとの連携
```python
# テーブルの作成
glueContext.write_dynamic_frame.from_catalog(
    frame=dynamic_frame,
    database="my_database",
    table_name="processed_table"
)

# パーティション付きテーブルの作成
glueContext.write_dynamic_frame.from_catalog(
    frame=dynamic_frame,
    database="my_database",
    table_name="partitioned_table",
    partition_keys=["city", "year"]
)
```

### 実践的な使用例

#### データクリーニング
```python
# 欠損値の処理
df_cleaned = df.na.fill({
    "age": 0,
    "city": "unknown"
})

# 異常値の除去
df_filtered = df.filter(
    (col("age") > 0) & (col("age") < 120)
)

# データ型の変換
df_converted = df.withColumn(
    "age",
    col("age").cast("integer")
)
```

#### データ分析
```python
# 年齢分布の分析
age_distribution = df.groupBy("city").agg(
    count("*").alias("total"),
    avg("age").alias("avg_age"),
    min("age").alias("min_age"),
    max("age").alias("max_age")
).orderBy("avg_age", ascending=False)

age_distribution.show()

# 年齢層別の集計
df_with_age_group = df.withColumn(
    "age_group",
    when(col("age") < 20, "10代")
    .when(col("age") < 30, "20代")
    .when(col("age") < 40, "30代")
    .when(col("age") < 50, "40代")
    .otherwise("50代以上")
)

age_group_summary = df_with_age_group.groupBy("age_group").count()
age_group_summary.show()
```

#### データの保存
```python
# CSVファイルとして保存
df.write.mode("overwrite").csv("s3://bucket-name/output/")

# Parquetファイルとして保存
df.write.mode("overwrite").parquet("s3://bucket-name/output/")

# JSONファイルとして保存
df.write.mode("overwrite").json("s3://bucket-name/output/")

# パーティション付きで保存
df.write.partitionBy("city").mode("overwrite").parquet("s3://bucket-name/output/")
```

### パフォーマンス最適化

#### キャッシュの活用
```python
# 頻繁に使用するDataFrameをキャッシュ
df.cache()
df.persist()

# キャッシュの確認
print(df.is_cached)

# キャッシュの解除
df.unpersist()
```

#### パーティショニング
```python
# パーティション数の調整
df.repartition(10).write.parquet("s3://bucket-name/output/")

# 特定の列でパーティション
df.repartition("city").write.parquet("s3://bucket-name/output/")

# パーティション数の最適化
df.coalesce(5).write.parquet("s3://bucket-name/output/")
```

#### ブロードキャスト結合
```python
# 小さいDataFrameをブロードキャスト
from pyspark.sql.functions import broadcast

df_large = spark.read.parquet("s3://bucket-name/large_table/")
df_small = spark.read.parquet("s3://bucket-name/small_table/")

# ブロードキャスト結合
df_joined = df_large.join(broadcast(df_small), "id")
```

## まとめ

### 学んだことの振り返り
- **AWS Glue DataFrame**: 構造化データ処理の基本
- **基本操作**: データの読み込み、表示、変換
- **データ処理**: フィルタリング、集計、結合
- **AWS Glue特有機能**: DynamicFrame、データカタログ連携
- **実践的活用**: データクリーニング、分析、保存

### 次のステップへの提案
1. **AWS Glue ETLジョブ**: 自動化されたデータ処理パイプライン
2. **データカタログ**: メタデータ管理とテーブル定義
3. **Glue DataBrew**: 視覚的なデータ準備ツール
4. **Glue Studio**: ノーコードETL開発環境
5. **パフォーマンス最適化**: 大規模データの効率的な処理
6. **データ品質**: データ検証とモニタリング

AWS Glue DataFrameは、クラウド上での大規模データ処理を効率的に行うための重要な技術です。基本的な概念を理解した後は、実際のプロジェクトで活用することで、より実践的なスキルを身につけることができます。 
