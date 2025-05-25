# PromQL ガイド

PromQL（Prometheus Query Language）は、Prometheusの時系列データをクエリするための言語です。このガイドでは、基本的なPromQLの使い方とよく使用されるクエリについて説明します。

## 基本的なクエリ

### メトリクスの選択

```promql
# 特定のメトリクスを選択
node_memory_MemTotal_bytes

# ラベルでフィルタリング
node_memory_MemTotal_bytes{instance="localhost:9100"}

# 複数のラベルでフィルタリング
node_memory_MemTotal_bytes{instance="localhost:9100", job="node_exporter"}
```

### 時間範囲の指定

```promql
# 直近5分間のデータ
node_memory_MemTotal_bytes[5m]

# 直近1時間のデータ
node_memory_MemTotal_bytes[1h]
```

## 演算子

### 算術演算子

```promql
# 加算
node_memory_MemTotal_bytes + node_memory_MemFree_bytes

# 減算
node_memory_MemTotal_bytes - node_memory_MemFree_bytes

# 乗算
node_memory_MemTotal_bytes * 2

# 除算
node_memory_MemTotal_bytes / 1024 / 1024  # バイトからメガバイトに変換
```

### 比較演算子

```promql
# より大きい
node_memory_MemTotal_bytes > 1000000000

# より小さい
node_memory_MemTotal_bytes < 2000000000

# 等しい
node_memory_MemTotal_bytes == 8589934592
```

## 集約関数

### 基本的な集約

```promql
# 合計
sum(node_memory_MemTotal_bytes)

# 平均
avg(node_memory_MemTotal_bytes)

# 最小値
min(node_memory_MemTotal_bytes)

# 最大値
max(node_memory_MemTotal_bytes)

# カウント
count(node_memory_MemTotal_bytes)
```

### グループ化

```promql
# インスタンスごとの合計
sum by (instance) (node_memory_MemTotal_bytes)

# 複数のラベルでグループ化
sum by (instance, job) (node_memory_MemTotal_bytes)
```

## よく使うクエリ例

### CPU使用率

```promql
# CPU使用率（1 - アイドル時間）
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### メモリ使用率

```promql
# メモリ使用率
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100
```

### ディスク使用率

```promql
# ディスク使用率
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```

### ネットワークトラフィック

```promql
# 受信トラフィック（バイト/秒）
rate(node_network_receive_bytes_total[5m])

# 送信トラフィック（バイト/秒）
rate(node_network_transmit_bytes_total[5m])
```

## 便利な関数

### rate()

```promql
# 5分間の平均変化率
rate(node_network_receive_bytes_total[5m])
```

### increase()

```promql
# 指定期間の増加量
increase(node_network_receive_bytes_total[1h])
```

### irate()

```promql
# 最後の2つのデータポイントの変化率
irate(node_network_receive_bytes_total[5m])
```

## 注意事項

- クエリの結果は、選択した時間範囲によって異なります
- 集約関数を使用する際は、適切なラベルでグループ化することをお勧めします
- より詳細な情報や高度なクエリについては、[公式ドキュメント](https://prometheus.io/docs/prometheus/latest/querying/basics/)を参照してください 
