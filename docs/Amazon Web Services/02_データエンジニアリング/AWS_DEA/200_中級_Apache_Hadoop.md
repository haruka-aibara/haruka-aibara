# Apache Hadoop (難易度レベル: 200)

## 概要
Apache Hadoopは、大規模データの分散処理を可能にするオープンソースのフレームワークです。GoogleのMapReduceとGoogle File System（GFS）の論文を基に開発され、複数のコンピュータを連携させて大規模データを効率的に処理するための基盤技術として広く活用されています。

Apache Hadoopを学ぶ意義：
- 大規模データ処理の基盤技術の理解
- 分散システムの設計原理の習得
- ビッグデータエコシステムの全体像の把握
- スケーラブルなデータ処理システムの構築

## 詳細

### Apache Hadoopとは

#### 基本的な概念
Apache Hadoopは、以下の4つの主要な特徴を持つ分散処理フレームワークです：

- **分散処理**: 複数のノードで並列処理を実行
- **耐障害性**: ノード障害時の自動復旧機能
- **スケーラビリティ**: 水平スケーリングによる容量拡張
- **コスト効率**: 汎用ハードウェアでの運用

#### アーキテクチャの構成要素
Hadoopは以下の主要コンポーネントで構成されています：

- **HDFS（Hadoop Distributed File System）**: 分散ファイルシステム
- **YARN（Yet Another Resource Negotiator）**: リソース管理・ジョブスケジューリング
- **MapReduce**: 分散処理プログラミングモデル
- **Common**: 共通ライブラリとユーティリティ

### HDFS（Hadoop Distributed File System）

#### HDFSの基本概念
HDFSは、大規模データを複数のノードに分散して保存するファイルシステムです。

#### アーキテクチャ
```bash
# HDFSの構成要素
NameNode          # メタデータ管理（マスターノード）
├── DataNode1     # データ保存（スレーブノード）
├── DataNode2     # データ保存（スレーブノード）
└── DataNode3     # データ保存（スレーブノード）
```

#### 基本的な操作
```bash
# HDFSの基本コマンド

# ファイルのアップロード
hdfs dfs -put local_file.txt /user/hadoop/

# ファイルのダウンロード
hdfs dfs -get /user/hadoop/file.txt local_file.txt

# ファイル一覧の表示
hdfs dfs -ls /user/hadoop/

# ファイルの削除
hdfs dfs -rm /user/hadoop/file.txt

# ディレクトリの作成
hdfs dfs -mkdir /user/hadoop/new_directory

# ファイルの内容表示
hdfs dfs -cat /user/hadoop/file.txt

# ファイルのコピー
hdfs dfs -cp /user/hadoop/source.txt /user/hadoop/destination.txt
```

#### レプリケーション
```bash
# レプリケーション数の設定
hdfs dfs -setrep -w 3 /user/hadoop/file.txt

# レプリケーション数の確認
hdfs dfs -ls -R /user/hadoop/
```

### YARN（Yet Another Resource Negotiator）

#### YARNの役割
YARNは、Hadoopクラスターのリソース管理とジョブスケジューリングを担当します。

#### アーキテクチャ
```bash
# YARNの構成要素
ResourceManager    # リソース管理（マスターノード）
├── NodeManager1   # リソース監視（スレーブノード）
├── NodeManager2   # リソース監視（スレーブノード）
└── NodeManager3   # リソース監視（スレーブノード）
```

#### リソース管理
```bash
# YARNの基本コマンド

# アプリケーション一覧の表示
yarn application -list

# 特定アプリケーションの詳細表示
yarn application -status application_1234567890_0001

# アプリケーションの強制終了
yarn application -kill application_1234567890_0001

# ノード一覧の表示
yarn node -list

# キュー情報の表示
yarn queue -status default
```

### MapReduce

#### MapReduceの基本概念
MapReduceは、大規模データの並列処理を行うためのプログラミングモデルです。

#### 処理フロー
```python
# MapReduceの処理フロー例

# 1. Map処理（データの変換）
def map_function(key, value):
    """
    入力データを処理して中間結果を生成
    """
    words = value.split()
    for word in words:
        yield (word, 1)

# 2. Reduce処理（結果の集約）
def reduce_function(key, values):
    """
    中間結果を集約して最終結果を生成
    """
    total = sum(values)
    return (key, total)

# 3. 実行例
# 入力: "Hello World Hello Hadoop"
# Map出力: [("Hello", 1), ("World", 1), ("Hello", 1), ("Hadoop", 1)]
# Reduce出力: [("Hello", 2), ("World", 1), ("Hadoop", 1)]
```

#### JavaでのMapReduce実装
```java
// WordCountのMapReduce実装例
import java.io.IOException;
import java.util.StringTokenizer;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {
    
    // Mapperクラス
    public static class TokenizerMapper extends Mapper<Object, Text, Text, IntWritable> {
        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();
        
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            StringTokenizer itr = new StringTokenizer(value.toString());
            while (itr.hasMoreTokens()) {
                word.set(itr.nextToken());
                context.write(word, one);
            }
        }
    }
    
    // Reducerクラス
    public static class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
        private IntWritable result = new IntWritable();
        
        public void reduce(Text key, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            result.set(sum);
            context.write(key, result);
        }
    }
    
    // メイン関数
    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "word count");
        job.setJarByClass(WordCount.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

### 実践的な使用例

#### ログ分析システム
```python
# ログ分析のMapReduce例

# ログデータの例
# 2024-01-01 10:00:00 user1 login success
# 2024-01-01 10:01:00 user2 login failed
# 2024-01-01 10:02:00 user1 logout success

def log_analyzer_map(key, value):
    """
    ログデータを解析してユーザー別のアクセス回数をカウント
    """
    parts = value.split()
    if len(parts) >= 4:
        user = parts[2]
        action = parts[3]
        yield (user, (action, 1))

def log_analyzer_reduce(key, values):
    """
    ユーザー別のアクション集計
    """
    action_counts = {}
    for action, count in values:
        if action in action_counts:
            action_counts[action] += count
        else:
            action_counts[action] = count
    
    for action, count in action_counts.items():
        yield (key, f"{action}: {count}")
```

#### データクリーニング
```python
# データクリーニングのMapReduce例

def data_cleaner_map(key, value):
    """
    データのクリーニング処理
    """
    # 空行の除去
    if not value.strip():
        return
    
    # 特殊文字の除去
    cleaned_value = re.sub(r'[^\w\s]', '', value)
    
    # 長さチェック
    if len(cleaned_value) > 0:
        yield (None, cleaned_value)

def data_cleaner_reduce(key, values):
    """
    クリーニング済みデータの出力
    """
    for value in values:
        yield (None, value)
```

### Hadoopエコシステム

#### 主要なコンポーネント
```bash
# Hadoopエコシステムの構成

Hadoop Core
├── HDFS          # 分散ファイルシステム
├── YARN          # リソース管理
└── MapReduce     # 分散処理

Data Processing
├── Apache Spark  # 高速分散処理
├── Apache Flink  # ストリーミング処理
└── Apache Storm  # リアルタイム処理

Data Storage
├── Apache HBase  # NoSQLデータベース
├── Apache Hive   # SQL on Hadoop
└── Apache Pig    # データフロー言語

Data Ingestion
├── Apache Kafka  # メッセージング
├── Apache Flume  # ログ収集
└── Apache Sqoop  # データ転送
```

#### Hive（SQL on Hadoop）
```sql
-- Hiveでのテーブル作成
CREATE TABLE users (
    user_id INT,
    username STRING,
    email STRING,
    created_date DATE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

-- データの挿入
INSERT INTO TABLE users VALUES
(1, 'user1', 'user1@example.com', '2024-01-01'),
(2, 'user2', 'user2@example.com', '2024-01-02');

-- クエリの実行
SELECT username, COUNT(*) as login_count
FROM users u
JOIN login_logs l ON u.user_id = l.user_id
WHERE l.login_date >= '2024-01-01'
GROUP BY username
ORDER BY login_count DESC;
```

#### HBase（NoSQLデータベース）
```java
// HBaseの基本操作例
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;

public class HBaseExample {
    
    public static void main(String[] args) throws Exception {
        Configuration config = HBaseConfiguration.create();
        Connection connection = ConnectionFactory.createConnection(config);
        Table table = connection.getTable(TableName.valueOf("users"));
        
        // データの挿入
        Put put = new Put(Bytes.toBytes("user1"));
        put.addColumn(
            Bytes.toBytes("info"),
            Bytes.toBytes("name"),
            Bytes.toBytes("田中太郎")
        );
        table.put(put);
        
        // データの取得
        Get get = new Get(Bytes.toBytes("user1"));
        Result result = table.get(get);
        String name = Bytes.toString(result.getValue(
            Bytes.toBytes("info"),
            Bytes.toBytes("name")
        ));
        
        table.close();
        connection.close();
    }
}
```

### クラスター管理

#### クラスターの設定
```bash
# core-site.xml（HDFS設定）
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://namenode:9000</value>
    </property>
</configuration>

# hdfs-site.xml（HDFS詳細設定）
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/hadoop/hdfs/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/hadoop/hdfs/datanode</value>
    </property>
</configuration>

# yarn-site.xml（YARN設定）
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>resourcemanager</value>
    </property>
</configuration>
```

#### クラスターの起動・停止
```bash
# HDFSの起動
start-dfs.sh

# YARNの起動
start-yarn.sh

# MapReduce履歴サーバーの起動
mr-jobhistory-daemon.sh start historyserver

# 全サービスの停止
stop-all.sh

# 個別サービスの停止
stop-dfs.sh
stop-yarn.sh
```

#### 監視とメンテナンス
```bash
# クラスターの状態確認
hdfs dfsadmin -report

# ノードの状態確認
yarn node -list

# ディスク使用量の確認
hdfs dfsadmin -report | grep "Configured Capacity"

# ブロックの整合性チェック
hdfs fsck /

# 安全モードの確認
hdfs dfsadmin -safemode get
```

### パフォーマンス最適化

#### 設定の最適化
```bash
# mapred-site.xml（MapReduce最適化）
<configuration>
    <property>
        <name>mapreduce.map.memory.mb</name>
        <value>2048</value>
    </property>
    <property>
        <name>mapreduce.reduce.memory.mb</name>
        <value>4096</value>
    </property>
    <property>
        <name>mapreduce.map.java.opts</name>
        <value>-Xmx1638m</value>
    </property>
    <property>
        <name>mapreduce.reduce.java.opts</name>
        <value>-Xmx3276m</value>
    </property>
</configuration>
```

#### データ最適化
```bash
# ファイルの圧縮
hdfs dfs -setrep -w 1 /user/hadoop/large_file.txt
hadoop jar hadoop-streaming.jar \
    -input /user/hadoop/large_file.txt \
    -output /user/hadoop/compressed \
    -mapper "gzip" \
    -reducer "cat"

# パーティショニング
hadoop jar hadoop-streaming.jar \
    -input /user/hadoop/data \
    -output /user/hadoop/partitioned \
    -mapper "cat" \
    -reducer "cat" \
    -partitioner org.apache.hadoop.mapred.lib.HashPartitioner \
    -numReduceTasks 10
```

## まとめ

### 学んだことの振り返り
- **Hadoop**: 大規模データ分散処理の基盤技術
- **HDFS**: 分散ファイルシステムによるデータ保存
- **YARN**: リソース管理とジョブスケジューリング
- **MapReduce**: 分散処理プログラミングモデル
- **エコシステム**: 様々なツールとの連携
- **最適化**: パフォーマンスとリソース管理

### 次のステップへの提案
1. **Apache Spark**: 高速分散処理フレームワーク
2. **Apache Kafka**: リアルタイムデータストリーミング
3. **Apache Hive**: SQL on Hadoop
4. **Apache HBase**: NoSQLデータベース
5. **クラウドHadoop**: AWS EMR、Azure HDInsight
6. **データパイプライン**: エンドツーエンドのデータ処理

Apache Hadoopは、ビッグデータ処理の基盤となる重要な技術です。基本的な概念を理解した後は、実際のプロジェクトで活用することで、より実践的なスキルを身につけることができます。 
