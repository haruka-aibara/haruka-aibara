# Docker メトリクス監視ガイド

Dockerコンテナのメトリクスを監視するためのガイドです。PrometheusとGrafanaを使用して、Dockerコンテナのパフォーマンスとリソース使用状況を監視する方法を説明します。

## 基本的なメトリクス

### コンテナの基本メトリクス

1. **CPU使用率**
   ```promql
   # コンテナごとのCPU使用率
   sum by (container_name) (rate(container_cpu_usage_seconds_total{container!=""}[5m])) * 100
   
   # コンテナごとのCPU制限に対する使用率
   sum by (container_name) (rate(container_cpu_usage_seconds_total{container!=""}[5m])) 
   / 
   sum by (container_name) (container_spec_cpu_quota{container!=""}) * 100
   ```

2. **メモリ使用量**
   ```promql
   # コンテナごとのメモリ使用量
   container_memory_usage_bytes{container!=""}
   
   # メモリ制限に対する使用率
   container_memory_usage_bytes{container!=""} 
   / 
   container_spec_memory_limit_bytes{container!=""} * 100
   ```

3. **ディスクI/O**
   ```promql
   # 読み取りバイト数
   sum by (container_name) (rate(container_fs_reads_bytes_total{container!=""}[5m]))
   
   # 書き込みバイト数
   sum by (container_name) (rate(container_fs_writes_bytes_total{container!=""}[5m]))
   ```

### ネットワークメトリクス

1. **ネットワークトラフィック**
   ```promql
   # 受信トラフィック
   sum by (container_name) (rate(container_network_receive_bytes_total{container!=""}[5m]))
   
   # 送信トラフィック
   sum by (container_name) (rate(container_network_transmit_bytes_total{container!=""}[5m]))
   ```

2. **ネットワークエラー**
   ```promql
   # 受信エラー
   sum by (container_name) (rate(container_network_receive_errors_total{container!=""}[5m]))
   
   # 送信エラー
   sum by (container_name) (rate(container_network_transmit_errors_total{container!=""}[5m]))
   ```

## 実践的な監視設定

### コンテナの状態監視

```yaml
# コンテナの状態監視
Queries:
  - name: Container Status
    query: container_tasks_state{container!=""}
    legend: {{container_name}} - {{state}}
    
  - name: Container Restarts
    query: changes(container_start_time_seconds{container!=""}[5m])
    legend: {{container_name}}
```

### リソース使用率の監視

```yaml
# リソース使用率の監視
Queries:
  - name: CPU Usage
    query: sum by (container_name) (rate(container_cpu_usage_seconds_total{container!=""}[5m])) * 100
    legend: {{container_name}}
    
  - name: Memory Usage
    query: container_memory_usage_bytes{container!=""} / container_spec_memory_limit_bytes{container!=""} * 100
    legend: {{container_name}}
```

## アラート設定

### リソース使用率のアラート

```yaml
# CPU使用率のアラート
Alert:
  name: High CPU Usage
  condition: sum by (container_name) (rate(container_cpu_usage_seconds_total{container!=""}[5m])) * 100 > 80
  duration: 5m
  labels:
    severity: warning
  annotations:
    summary: High CPU usage detected
    description: Container {{ $labels.container_name }} has high CPU usage

# メモリ使用率のアラート
Alert:
  name: High Memory Usage
  condition: container_memory_usage_bytes{container!=""} / container_spec_memory_limit_bytes{container!=""} * 100 > 85
  duration: 5m
  labels:
    severity: warning
  annotations:
    summary: High memory usage detected
    description: Container {{ $labels.container_name }} has high memory usage
```

## ダッシュボード設定

### コンテナ概要ダッシュボード

```yaml
# ダッシュボード設定
Panels:
  - title: Container Overview
    type: table
    queries:
      - container_memory_usage_bytes{container!=""}
      - container_cpu_usage_seconds_total{container!=""}
      - container_network_receive_bytes_total{container!=""}
      - container_network_transmit_bytes_total{container!=""}
    columns:
      - container_name
      - memory_usage
      - cpu_usage
      - network_in
      - network_out
```

## 注意事項

- メトリクスの収集間隔を適切に設定してください
- アラートのしきい値は環境に応じて調整してください
- コンテナ名やラベルの命名規則を統一してください
- より詳細な設定や使用方法については、[公式ドキュメント](https://prometheus.io/docs/guides/node-exporter/)を参照してください 
