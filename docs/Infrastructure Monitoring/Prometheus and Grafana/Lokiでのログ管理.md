# Loki でのログ管理

## 問題

Prometheus でメトリクスを取得し Grafana でダッシュボードを作っているのに、ログだけは別のツール（CloudWatch Logs や Elasticsearch）を使っている。アラートが来るたびにツールを行き来しなければいけない。

Loki は Prometheus と同じ思想で作られたログ収集ツール。Grafana と統合されているので、メトリクスのグラフから同じ画面のままログを掘り下げられる。

---

## Loki の特徴

Elasticsearch との主な違い：

| | Loki | Elasticsearch |
|--|------|---------------|
| インデックス対象 | ラベル（メタデータ）のみ | ログ本文全体 |
| ストレージコスト | 安い | 高い |
| クエリ方法 | LogQL（PromQL に似た構文） | Lucene クエリ |
| 向いている用途 | Grafana と統合したい、コスト抑えたい | 全文検索・高度な分析 |

ログ本文をインデックスしないので安い反面、全文検索の性能は Elasticsearch に劣る。

---

## 構成

```
アプリ / システムログ
    ↓
Promtail（ログ収集エージェント）
    ↓
Loki（ログ保存・クエリ）
    ↓
Grafana（可視化・検索）
```

Kubernetes 環境では Promtail を DaemonSet で各ノードに配置するのが一般的。

---

## セットアップ（Docker Compose）

```yaml
# docker-compose.yml
version: "3"
services:
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./loki-config.yaml:/etc/loki/local-config.yaml
    command: -config.file=/etc/loki/local-config.yaml

  promtail:
    image: grafana/promtail:latest
    volumes:
      - /var/log:/var/log:ro
      - ./promtail-config.yaml:/etc/promtail/config.yaml
    command: -config.file=/etc/promtail/config.yaml

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
```

```yaml
# promtail-config.yaml
server:
  http_listen_port: 9080

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: system
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: /var/log/*.log
```

---

## LogQL の基本

Grafana の Explore で Loki をデータソースに選択して LogQL を書く。

```logql
# job="myapp" のログを表示
{job="myapp"}

# エラーログだけ絞り込む
{job="myapp"} |= "ERROR"

# 正規表現でフィルタ
{job="myapp"} |~ "timeout|connection refused"

# ログから数値を抽出してメトリクス化（エラー数/分）
sum(rate({job="myapp"} |= "ERROR" [1m]))
```

ラベルで絞り込んでから `|=` でログ本文をフィルタするのが基本の流れ。

---

## Kubernetes での Promtail 設定

```yaml
# DaemonSet で各ノードのログを収集
scrape_configs:
  - job_name: kubernetes-pods
    kubernetes_sd_configs:
      - role: pod
    pipeline_stages:
      - docker: {}       # Docker のログ形式をパース
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_name]
        target_label: pod
      - source_labels: [__meta_kubernetes_namespace]
        target_label: namespace
      - source_labels: [__meta_kubernetes_pod_container_name]
        target_label: container
```

Pod 名・Namespace・コンテナ名がラベルとして付くので、Grafana 上で `{namespace="production", pod=~"myapp-.*"}` のように絞り込める。

---

## Grafana でメトリクスとログを一緒に見る

Grafana のダッシュボードで Prometheus のメトリクスグラフと Loki のログパネルを並べることができる。

「エラー率が上昇したタイムスタンプ付近のログを見たい」というときに、グラフ上の時間範囲を選択するとログパネルもその時間帯に絞れる。ツール間の行き来が不要になる。

Explore 画面では「Metrics to Logs」ボタンで、Prometheus のメトリクスから同じ時間帯の Loki ログに直接ジャンプできる。
