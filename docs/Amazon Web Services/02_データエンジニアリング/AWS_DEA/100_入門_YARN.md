# YARN (難易度レベル: 100)

## 概要
YARN（Yet Another Resource Negotiator）は、Apache Hadoopのリソース管理とジョブスケジューリングを担当するコンポーネントです。Hadoop 2.0で導入され、クラスター内のリソース（CPU、メモリ）を効率的に管理し、複数のアプリケーションが同時に実行できるようにする重要な役割を果たします。

YARNを学ぶ意義：
- Hadoopクラスターのリソース管理の理解
- 分散システムのスケジューリング原理の習得
- 大規模データ処理の基盤知識
- クラスター運用の効率化

## 詳細

### YARNとは

#### 基本的な概念
YARNは、Hadoopクラスターのリソース管理とジョブスケジューリングを行うシステムです。以下の特徴があります：

- **リソース管理**: CPU、メモリなどのリソースを効率的に分配
- **ジョブスケジューリング**: 複数のアプリケーションの実行を管理
- **スケーラビリティ**: 大規模クラスターでの運用に対応
- **柔軟性**: 様々なアプリケーションフレームワークをサポート

#### YARNの役割
```bash
# YARNの主要機能
1. リソース管理    # クラスター内のリソースを監視・分配
2. ジョブスケジューリング  # アプリケーションの実行順序を管理
3. アプリケーション管理   # 各アプリケーションのライフサイクルを管理
4. フェイルオーバー      # 障害時の自動復旧
```

### YARNのアーキテクチャ

#### 基本構成
YARNは以下の主要コンポーネントで構成されています：

```bash
# YARNアーキテクチャ
ResourceManager    # マスターノード（リソース管理）
├── NodeManager1   # スレーブノード1（リソース監視）
├── NodeManager2   # スレーブノード2（リソース監視）
└── NodeManager3   # スレーブノード3（リソース監視）
```

#### 各コンポーネントの役割

##### ResourceManager（リソースマネージャー）
```bash
# ResourceManagerの機能
- クラスター全体のリソース管理
- アプリケーションのスケジューリング
- リソースの分配と監視
- アプリケーションのライフサイクル管理
```

##### NodeManager（ノードマネージャー）
```bash
# NodeManagerの機能
- 各ノードのリソース監視
- コンテナの管理
- リソース使用量の報告
- アプリケーションの実行
```

##### ApplicationMaster（アプリケーションマスター）
```bash
# ApplicationMasterの機能
- 個別アプリケーションの管理
- リソース要求の管理
- タスクの実行監視
- アプリケーションの状態管理
```

### YARNの基本操作

#### クラスター情報の確認
```bash
# YARNの基本コマンド

# アプリケーション一覧の表示
yarn application -list

# 実行中のアプリケーションのみ表示
yarn application -list -appStates RUNNING

# 特定のアプリケーションの詳細表示
yarn application -status application_1234567890_0001

# アプリケーションの強制終了
yarn application -kill application_1234567890_0001

# ノード一覧の表示
yarn node -list

# ノードの詳細情報表示
yarn node -status <node_id>

# キュー情報の表示
yarn queue -status default

# クラスターの統計情報
yarn rmadmin -getServiceState rm
```

#### リソース使用状況の確認
```bash
# リソース使用状況の確認

# クラスターの概要情報
yarn cluster --list

# リソース使用量の詳細
yarn cluster --info

# アプリケーションのリソース使用量
yarn application -status <application_id> | grep "Memory"

# ノード別のリソース使用量
yarn node -list -all | grep "Memory"
```

### YARNの設定

#### 基本設定ファイル
```xml
<!-- yarn-site.xml（YARNの基本設定） -->
<configuration>
    <!-- ResourceManagerのホスト名 -->
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>resourcemanager.example.com</value>
    </property>
    
    <!-- NodeManagerの補助サービス -->
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    
    <!-- コンテナの最小メモリ -->
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>256</value>
    </property>
    
    <!-- コンテナの最大メモリ -->
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>8192</value>
    </property>
    
    <!-- コンテナの最小CPU -->
    <property>
        <name>yarn.scheduler.minimum-allocation-vcores</name>
        <value>1</value>
    </property>
    
    <!-- コンテナの最大CPU -->
    <property>
        <name>yarn.scheduler.maximum-allocation-vcores</name>
        <value>4</value>
    </property>
</configuration>
```

#### スケジューラーの設定
```xml
<!-- Capacity Schedulerの設定例 -->
<configuration>
    <!-- スケジューラーの種類 -->
    <property>
        <name>yarn.resourcemanager.scheduler.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
    </property>
    
    <!-- キューの設定 -->
    <property>
        <name>yarn.scheduler.capacity.root.queues</name>
        <value>default,production,development</value>
    </property>
    
    <!-- デフォルトキューの容量 -->
    <property>
        <name>yarn.scheduler.capacity.root.default.capacity</name>
        <value>50</value>
    </property>
    
    <!-- 本番キューの容量 -->
    <property>
        <name>yarn.scheduler.capacity.root.production.capacity</name>
        <value>30</value>
    </property>
    
    <!-- 開発キューの容量 -->
    <property>
        <name>yarn.scheduler.capacity.root.development.capacity</name>
        <value>20</value>
    </property>
</configuration>
```

### 実践的な使用例

#### 基本的なジョブ実行
```bash
# MapReduceジョブの実行例

# 1. ジョブの実行
hadoop jar hadoop-mapreduce-examples.jar wordcount \
    /input/text_files \
    /output/word_count

# 2. ジョブの状態確認
yarn application -list

# 3. ジョブの詳細確認
yarn application -status <application_id>

# 4. ジョブのログ確認
yarn logs -applicationId <application_id>
```

#### リソース制限付きジョブ実行
```bash
# リソース制限を指定したジョブ実行

# メモリ制限付きでジョブ実行
hadoop jar myapp.jar MyJob \
    -D mapreduce.map.memory.mb=2048 \
    -D mapreduce.reduce.memory.mb=4096 \
    /input/data \
    /output/result

# CPU制限付きでジョブ実行
hadoop jar myapp.jar MyJob \
    -D yarn.app.mapreduce.am.resource.vcores=2 \
    -D mapreduce.map.cpu.vcores=1 \
    -D mapreduce.reduce.cpu.vcores=2 \
    /input/data \
    /output/result
```

#### キューの使用
```bash
# 特定のキューを使用したジョブ実行

# 本番キューでジョブ実行
hadoop jar myapp.jar MyJob \
    -D mapreduce.job.queuename=production \
    /input/data \
    /output/result

# 開発キューでジョブ実行
hadoop jar myapp.jar MyJob \
    -D mapreduce.job.queuename=development \
    /input/data \
    /output/result
```

### 監視とメンテナンス

#### クラスターの監視
```bash
# クラスター監視のコマンド

# 全体的な状態確認
yarn cluster --list

# リソース使用状況の確認
yarn cluster --info

# アプリケーションの統計
yarn application -list -appStates ALL

# ノードの健康状態
yarn node -list -all

# キューの使用状況
yarn queue -status default
```

#### ログの確認
```bash
# ログ確認のコマンド

# アプリケーションのログ
yarn logs -applicationId <application_id>

# 特定のコンテナのログ
yarn logs -applicationId <application_id> -containerId <container_id>

# ログのダウンロード
yarn logs -applicationId <application_id> -logFiles stdout,stderr

# ログの検索
yarn logs -applicationId <application_id> | grep "ERROR"
```

#### トラブルシューティング
```bash
# トラブルシューティングのコマンド

# ResourceManagerの状態確認
yarn rmadmin -getServiceState rm

# NodeManagerの状態確認
yarn node -list -all | grep "UNHEALTHY"

# アプリケーションの強制終了
yarn application -kill <application_id>

# キューのリセット
yarn rmadmin -refreshQueues

# ノードの追加・削除
yarn rmadmin -refreshNodes
```

### YARNのスケジューラー

#### 利用可能なスケジューラー
```bash
# YARNで利用可能なスケジューラー

1. FIFO Scheduler（First In, First Out）
   - 単純な順序実行
   - 小規模クラスター向け

2. Capacity Scheduler
   - キューベースのリソース管理
   - 大規模クラスター向け

3. Fair Scheduler
   - 公平なリソース分配
   - 多様なワークロード向け
```

#### スケジューラーの選択
```xml
<!-- スケジューラーの設定例 -->

<!-- Capacity Scheduler -->
<property>
    <name>yarn.resourcemanager.scheduler.class</name>
    <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
</property>

<!-- Fair Scheduler -->
<property>
    <name>yarn.resourcemanager.scheduler.class</name>
    <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler</value>
</property>
```

### パフォーマンス最適化

#### リソース設定の最適化
```xml
<!-- パフォーマンス最適化の設定例 -->
<configuration>
    <!-- コンテナのメモリ設定 -->
    <property>
        <name>yarn.scheduler.minimum-allocation-mb</name>
        <value>512</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-mb</name>
        <value>16384</value>
    </property>
    
    <!-- コンテナのCPU設定 -->
    <property>
        <name>yarn.scheduler.minimum-allocation-vcores</name>
        <value>1</value>
    </property>
    <property>
        <name>yarn.scheduler.maximum-allocation-vcores</name>
        <value>8</value>
    </property>
    
    <!-- アプリケーションの最大実行時間 -->
    <property>
        <name>yarn.resourcemanager.am.lifetime-monitoring.enabled</name>
        <value>true</value>
    </property>
</configuration>
```

#### キューの最適化
```xml
<!-- キューの最適化設定 -->
<configuration>
    <!-- キューの優先度設定 -->
    <property>
        <name>yarn.scheduler.capacity.root.production.priority</name>
        <value>10</value>
    </property>
    <property>
        <name>yarn.scheduler.capacity.root.development.priority</name>
        <value>5</value>
    </property>
    
    <!-- キューの最大実行時間 -->
    <property>
        <name>yarn.scheduler.capacity.root.production.maximum-application-lifetime</name>
        <value>7200</value>
    </property>
</configuration>
```

## まとめ

### 学んだことの振り返り
- **YARN**: Hadoopクラスターのリソース管理システム
- **アーキテクチャ**: ResourceManager、NodeManager、ApplicationMaster
- **基本操作**: アプリケーション管理、リソース監視
- **設定**: スケジューラー、キューの設定
- **監視**: ログ確認、トラブルシューティング
- **最適化**: リソース設定、パフォーマンス調整

### 次のステップへの提案
1. **Apache Hadoop**: 完全なHadoopエコシステムの理解
2. **MapReduce**: 分散処理プログラミング
3. **Apache Spark**: YARN上でのSpark実行
4. **クラスター管理**: 大規模クラスターの運用
5. **パフォーマンスチューニング**: 高度な最適化手法
6. **クラウドHadoop**: AWS EMR、Azure HDInsight

YARNは、Hadoopクラスターの効率的な運用に不可欠な重要なコンポーネントです。基本的な概念を理解した後は、実際のクラスターで活用することで、より実践的なスキルを身につけることができます。 
