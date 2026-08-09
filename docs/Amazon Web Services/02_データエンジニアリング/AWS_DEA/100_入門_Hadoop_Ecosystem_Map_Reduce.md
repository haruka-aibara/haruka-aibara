# Hadoopエコシステム Map・Reduceステップ (難易度レベル: 100)

## 概要
HadoopエコシステムのMap・Reduceステップは、大規模データを効率的に処理するための基本的なプログラミングモデルです。Mapステップでデータを分散処理し、Reduceステップで結果を集約することで、複数のコンピュータを連携させた並列処理を実現します。

Map・Reduceステップを学ぶ意義：
- 分散処理の基本概念の理解
- 大規模データ処理の仕組みの習得
- 並列処理の設計原理の把握
- ビッグデータ処理の基盤知識

## 詳細

### Map・Reduceとは

#### 基本的な概念
Map・Reduceは、大規模データの並列処理を行うためのプログラミングモデルです。以下の2つのステップで構成されています：

- **Mapステップ**: データを分割して並列処理
- **Reduceステップ**: 処理結果を集約して最終結果を生成

#### 処理の流れ
```
入力データ → Map処理 → 中間結果 → Reduce処理 → 最終結果
```

### Mapステップ

#### Mapステップの役割
Mapステップは、入力データを受け取り、キー・バリューペアの形式で中間結果を生成します。

#### 基本的な処理例
```python
# Mapステップの例：単語カウント

# 入力データ
input_data = [
    "Hello World Hello Hadoop",
    "World is beautiful",
    "Hadoop is powerful"
]

# Map処理
def map_function(line):
    """
    各行を単語に分割し、各単語をカウント
    """
    words = line.split()
    for word in words:
        yield (word, 1)

# Map処理の実行例
for line in input_data:
    for word, count in map_function(line):
        print(f"({word}, {count})")

# 出力例：
# (Hello, 1)
# (World, 1)
# (Hello, 1)
# (Hadoop, 1)
# (World, 1)
# (is, 1)
# (beautiful, 1)
# (Hadoop, 1)
# (is, 1)
# (powerful, 1)
```

#### 実践的なMap処理例

##### ログデータの解析
```python
# ログデータの例
log_data = [
    "2024-01-01 10:00:00 user1 login success",
    "2024-01-01 10:01:00 user2 login failed",
    "2024-01-01 10:02:00 user1 logout success",
    "2024-01-01 10:03:00 user3 login success"
]

def map_log_analysis(line):
    """
    ログデータを解析してユーザー別のアクションをカウント
    """
    parts = line.split()
    if len(parts) >= 4:
        user = parts[2]
        action = parts[3]
        return (user, action)
    return None

# 実行例
for line in log_data:
    result = map_log_analysis(line)
    if result:
        print(f"({result[0]}, {result[1]})")

# 出力例：
# (user1, login)
# (user2, login)
# (user1, logout)
# (user3, login)
```

##### データクリーニング
```python
# データクリーニングの例
raw_data = [
    "田中太郎,30,東京",
    "佐藤花子,25,大阪",
    "鈴木一郎,35,名古屋",
    ",,",  # 空データ
    "高橋美咲,28,福岡"
]

def map_data_cleaning(line):
    """
    データのクリーニング処理
    """
    if not line.strip():
        return None
    
    parts = line.split(',')
    if len(parts) >= 3 and all(parts):  # 全てのフィールドが存在
        name = parts[0].strip()
        age = parts[1].strip()
        city = parts[2].strip()
        return (name, f"{age},{city}")
    return None

# 実行例
for line in raw_data:
    result = map_data_cleaning(line)
    if result:
        print(f"({result[0]}, {result[1]})")

# 出力例：
# (田中太郎, 30,東京)
# (佐藤花子, 25,大阪)
# (鈴木一郎, 35,名古屋)
# (高橋美咲, 28,福岡)
```

### Reduceステップ

#### Reduceステップの役割
Reduceステップは、Mapステップで生成された中間結果を受け取り、同じキーを持つデータを集約して最終結果を生成します。

#### 基本的な処理例
```python
# Reduceステップの例：単語カウントの集約

# Mapステップの出力（中間結果）
intermediate_data = [
    ("Hello", 1), ("World", 1), ("Hello", 1), ("Hadoop", 1),
    ("World", 1), ("is", 1), ("beautiful", 1),
    ("Hadoop", 1), ("is", 1), ("powerful", 1)
]

# キー別にグループ化
grouped_data = {}
for key, value in intermediate_data:
    if key in grouped_data:
        grouped_data[key].append(value)
    else:
        grouped_data[key] = [value]

# Reduce処理
def reduce_function(key, values):
    """
    同じキーを持つ値を集約
    """
    total = sum(values)
    return (key, total)

# Reduce処理の実行
for key, values in grouped_data.items():
    result = reduce_function(key, values)
    print(f"({result[0]}, {result[1]})")

# 出力例：
# (Hello, 2)
# (World, 2)
# (Hadoop, 2)
# (is, 2)
# (beautiful, 1)
# (powerful, 1)
```

#### 実践的なReduce処理例

##### 統計情報の計算
```python
# 売上データの集計例
sales_data = [
    ("東京", 1000), ("大阪", 800), ("東京", 1200),
    ("名古屋", 600), ("大阪", 900), ("東京", 1100)
]

def reduce_sales_analysis(key, values):
    """
    地域別の売上統計を計算
    """
    total_sales = sum(values)
    avg_sales = total_sales / len(values)
    return (key, f"合計:{total_sales}, 平均:{avg_sales:.1f}")

# グループ化とReduce処理
grouped_sales = {}
for city, amount in sales_data:
    if city in grouped_sales:
        grouped_sales[city].append(amount)
    else:
        grouped_sales[city] = [amount]

# 実行
for city, amounts in grouped_sales.items():
    result = reduce_sales_analysis(city, amounts)
    print(f"{result[0]}: {result[1]}")

# 出力例：
# 東京: 合計:3300, 平均:1100.0
# 大阪: 合計:1700, 平均:850.0
# 名古屋: 合計:600, 平均:600.0
```

##### 最大値・最小値の計算
```python
# 気温データの分析例
temperature_data = [
    ("東京", 25), ("大阪", 28), ("東京", 22),
    ("名古屋", 26), ("大阪", 30), ("東京", 27)
]

def reduce_temperature_analysis(key, values):
    """
    地域別の気温統計を計算
    """
    max_temp = max(values)
    min_temp = min(values)
    avg_temp = sum(values) / len(values)
    return (key, f"最高:{max_temp}°C, 最低:{min_temp}°C, 平均:{avg_temp:.1f}°C")

# グループ化とReduce処理
grouped_temp = {}
for city, temp in temperature_data:
    if city in grouped_temp:
        grouped_temp[city].append(temp)
    else:
        grouped_temp[city] = [temp]

# 実行
for city, temps in grouped_temp.items():
    result = reduce_temperature_analysis(city, temps)
    print(f"{result[0]}: {result[1]}")

# 出力例：
# 東京: 最高:27°C, 最低:22°C, 平均:24.7°C
# 大阪: 最高:30°C, 最低:28°C, 平均:29.0°C
# 名古屋: 最高:26°C, 最低:26°C, 平均:26.0°C
```

### Map・Reduceの組み合わせ

#### 完全な処理フロー
```python
# 完全なMap・Reduce処理の例

# 1. 入力データ
input_text = [
    "Hello World Hello Hadoop",
    "World is beautiful",
    "Hadoop is powerful"
]

# 2. Map処理
def word_count_map(line):
    words = line.split()
    for word in words:
        yield (word.lower(), 1)

# 3. 中間結果の生成
intermediate_results = []
for line in input_text:
    for key, value in word_count_map(line):
        intermediate_results.append((key, value))

print("中間結果:")
for key, value in intermediate_results:
    print(f"({key}, {value})")

# 4. グループ化
grouped_results = {}
for key, value in intermediate_results:
    if key in grouped_results:
        grouped_results[key].append(value)
    else:
        grouped_results[key] = [value]

# 5. Reduce処理
def word_count_reduce(key, values):
    total = sum(values)
    return (key, total)

# 6. 最終結果の生成
final_results = []
for key, values in grouped_results.items():
    result = word_count_reduce(key, values)
    final_results.append(result)

print("\n最終結果:")
for key, value in final_results:
    print(f"'{key}': {value}回")

# 出力例：
# 中間結果:
# (hello, 1)
# (world, 1)
# (hello, 1)
# (hadoop, 1)
# (world, 1)
# (is, 1)
# (beautiful, 1)
# (hadoop, 1)
# (is, 1)
# (powerful, 1)
#
# 最終結果:
# 'hello': 2回
# 'world': 2回
# 'hadoop': 2回
# 'is': 2回
# 'beautiful': 1回
# 'powerful': 1回
```

### 実践的な応用例

#### 顧客購買分析
```python
# 顧客購買データの分析例

# 入力データ
purchase_data = [
    "customer1,productA,1000",
    "customer2,productB,1500",
    "customer1,productC,800",
    "customer3,productA,1000",
    "customer2,productA,1000"
]

# Map処理：顧客別の購買金額を抽出
def purchase_map(line):
    parts = line.split(',')
    if len(parts) >= 3:
        customer = parts[0]
        amount = int(parts[2])
        return (customer, amount)
    return None

# Reduce処理：顧客別の総購買金額を計算
def purchase_reduce(customer, amounts):
    total = sum(amounts)
    count = len(amounts)
    return (customer, f"総額:{total}円, 購入回数:{count}回")

# 処理実行
intermediate = []
for line in purchase_data:
    result = purchase_map(line)
    if result:
        intermediate.append(result)

# グループ化
grouped = {}
for customer, amount in intermediate:
    if customer in grouped:
        grouped[customer].append(amount)
    else:
        grouped[customer] = [amount]

# Reduce処理
print("顧客別購買分析:")
for customer, amounts in grouped.items():
    result = purchase_reduce(customer, amounts)
    print(f"{result[0]}: {result[1]}")

# 出力例：
# customer1: 総額:1800円, 購入回数:2回
# customer2: 総額:2500円, 購入回数:2回
# customer3: 総額:1000円, 購入回数:1回
```

#### 地域別売上分析
```python
# 地域別売上データの分析例

# 入力データ
sales_data = [
    "東京,2024-01-01,100000",
    "大阪,2024-01-01,80000",
    "東京,2024-01-02,120000",
    "名古屋,2024-01-01,60000",
    "大阪,2024-01-02,90000"
]

# Map処理：地域別の売上を抽出
def sales_map(line):
    parts = line.split(',')
    if len(parts) >= 3:
        region = parts[0]
        amount = int(parts[2])
        return (region, amount)
    return None

# Reduce処理：地域別の売上統計を計算
def sales_reduce(region, amounts):
    total = sum(amounts)
    avg = total / len(amounts)
    return (region, f"総売上:{total:,}円, 平均:{avg:,.0f}円")

# 処理実行
intermediate = []
for line in sales_data:
    result = sales_map(line)
    if result:
        intermediate.append(result)

# グループ化
grouped = {}
for region, amount in intermediate:
    if region in grouped:
        grouped[region].append(amount)
    else:
        grouped[region] = [amount]

# Reduce処理
print("地域別売上分析:")
for region, amounts in grouped.items():
    result = sales_reduce(region, amounts)
    print(f"{result[0]}: {result[1]}")

# 出力例：
# 東京: 総売上:220,000円, 平均:110,000円
# 大阪: 総売上:170,000円, 平均:85,000円
# 名古屋: 総売上:60,000円, 平均:60,000円
```

## まとめ

### 学んだことの振り返り
- **Mapステップ**: データの分散処理と中間結果の生成
- **Reduceステップ**: 中間結果の集約と最終結果の生成
- **処理フロー**: Map → 中間結果 → Reduce → 最終結果
- **実践的活用**: ログ分析、データクリーニング、統計計算
- **並列処理**: 複数ノードでの効率的なデータ処理

### 次のステップへの提案
1. **Apache Hadoop**: 実際の分散処理システムでの実装
2. **Apache Spark**: 高速分散処理フレームワーク
3. **データパイプライン**: エンドツーエンドのデータ処理
4. **ビッグデータ分析**: 大規模データの分析手法
5. **クラウドサービス**: AWS EMR、Azure HDInsight
6. **リアルタイム処理**: ストリーミングデータの処理

Map・Reduceステップは、ビッグデータ処理の基盤となる重要な概念です。基本的な原理を理解した後は、実際のシステムで活用することで、より実践的なスキルを身につけることができます。 
