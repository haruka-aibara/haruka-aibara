# Grafana ダッシュボード作成ガイド

Grafanaでは、様々なデータソースからデータを取得し、カスタマイズ可能なダッシュボードを作成できます。このガイドでは、ダッシュボードの作成方法と主要なデータソースとの接続について説明します。

## ダッシュボードの作成

### 新規ダッシュボードの作成

1. 左側のメニューから「+」をクリック
2. 「Create new dashboard」を選択
3. 「Add new panel」をクリック

## 主要なデータソースとの接続

### Prometheus

#### 基本的な接続設定

1. データソースの追加
   - Configuration → Data sources → Add data source
   - Prometheusを選択
   - URL: `http://localhost:9090`を設定

#### よく使うメトリクス

```promql
# CPU使用率
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# メモリ使用率
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100

# ディスク使用率
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```

### Node Exporter

Node Exporterのメトリクスは、Prometheusを経由して取得します。

#### 主要なメトリクス

```promql
# システム情報
node_uname_info

# CPU情報
node_cpu_seconds_total

# メモリ情報
node_memory_MemTotal_bytes
node_memory_MemFree_bytes

# ディスク情報
node_filesystem_size_bytes
node_filesystem_free_bytes
```

### InfluxDB

#### 接続設定

1. データソースの追加
   - Configuration → Data sources → Add data source
   - InfluxDBを選択
   - 以下の設定を行います：
     ```
     URL: http://localhost:8086
     Database: your_database
     User: your_username
     Password: your_password
     ```

#### クエリ例

```sql
SELECT mean("value") FROM "measurement" WHERE $timeFilter GROUP BY time($interval)
```

### MySQL

#### 接続設定

1. データソースの追加
   - Configuration → Data sources → Add data source
   - MySQLを選択
   - 以下の設定を行います：
     ```
     Host: localhost:3306
     Database: your_database
     User: your_username
     Password: your_password
     ```

#### クエリ例

```sql
SELECT
  time_sec,
  value
FROM
  your_table
WHERE
  $__timeFilter(time_sec)
```

## ダッシュボードのカスタマイズ

### パネルの追加

1. 「Add panel」をクリック
2. データソースを選択
3. クエリを入力
4. 可視化タイプを選択（Time series, Gauge, Stat など）

### 変数の使用

1. ダッシュボード設定を開く
2. 「Variables」タブを選択
3. 「Add variable」をクリック
4. 変数の種類を選択：
   - Query: データソースから値を取得
   - Custom: 手動で値を設定
   - Text box: テキスト入力
   - Constant: 固定値

### パネルの配置

- ドラッグ＆ドロップでパネルを移動
- パネルのサイズを調整
- グリッドレイアウトの設定

## ダッシュボードの共有

### エクスポート

1. ダッシュボード設定を開く
2. 「Share dashboard」をクリック
3. 「Export」タブを選択
4. JSONをダウンロード

### インポート

1. 「+」→「Import」をクリック
2. JSONファイルをアップロード
3. データソースのマッピングを設定

## 注意事項

- データソースの接続設定は、セキュリティを考慮して行ってください
- 本番環境では、適切な認証設定を行ってください
- ダッシュボードのバックアップを定期的に取得することをお勧めします
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/dashboards/)を参照してください 
