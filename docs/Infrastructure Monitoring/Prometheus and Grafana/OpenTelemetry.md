<!-- Space: harukaaibarapublic -->
<!-- Parent: Prometheus and Grafana -->
<!-- Title: OpenTelemetry -->

# OpenTelemetry——ログ・メトリクス・トレースを統一する

「サービスが遅い原因を調べたいが、どのサービスのどの処理がボトルネックかわからない」「ツールを変えるたびに計装コードを書き直した」——OpenTelemetry（OTel）はベンダー中立な計装の標準規格。一度コードを書けば、Datadog・Jaeger・Prometheus など好きなバックエンドに送れる。

---

## 3本柱

| シグナル | 内容 | 質問への答え |
|---|---|---|
| **Traces（トレース）** | リクエストが複数サービスを通る経路と時間 | 「どこが遅いか」 |
| **Metrics（メトリクス）** | 時系列の数値データ（CPU・リクエスト数等） | 「今どんな状態か」 |
| **Logs（ログ）** | 時刻付きのテキスト記録 | 「何が起きたか」 |

OpenTelemetry はこの3つを相互に関連付けて（例: トレースIDをログに付ける）、障害調査を「ログ → トレース → メトリクス」とシームレスに行き来できるようにする。

---

## アーキテクチャ

```
アプリ（SDK で計装）
    ↓
OTel Collector（集約・変換・ルーティング）
    ├→ Jaeger / Tempo（トレース）
    ├→ Prometheus（メトリクス）
    └→ Loki / Elasticsearch（ログ）
```

OTel Collector を挟むことで、バックエンドを変えてもアプリのコードを変更しなくていい。

---

## Python アプリへの計装

```bash
pip install opentelemetry-api opentelemetry-sdk \
            opentelemetry-exporter-otlp \
            opentelemetry-instrumentation-fastapi
```

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

# トレーサーのセットアップ
provider = TracerProvider()
exporter = OTLPSpanExporter(endpoint="http://otel-collector:4317")
provider.add_span_processor(BatchSpanProcessor(exporter))
trace.set_tracer_provider(provider)

# FastAPI の自動計装（リクエスト/レスポンスを自動でトレース）
app = FastAPI()
FastAPIInstrumentor.instrument_app(app)

# カスタムスパンを手動で作る
tracer = trace.get_tracer(__name__)

@app.get("/users/{user_id}")
async def get_user(user_id: str):
    with tracer.start_as_current_span("fetch_user") as span:
        span.set_attribute("user.id", user_id)
        user = await db.find_user(user_id)
        if not user:
            span.set_status(trace.StatusCode.ERROR, "User not found")
        return user
```

---

## OTel Collector の設定

```yaml
# otel-collector-config.yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 1s
  # 機密情報を削除する
  attributes:
    actions:
      - key: http.request.header.authorization
        action: delete

exporters:
  otlp/jaeger:
    endpoint: jaeger:4317
    tls:
      insecure: true
  prometheus:
    endpoint: "0.0.0.0:8889"

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp/jaeger]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
```

---

## Docker Compose でローカル環境を作る

```yaml
services:
  otel-collector:
    image: otel/opentelemetry-collector-contrib:latest
    volumes:
      - ./otel-collector-config.yaml:/etc/otelcol-contrib/config.yaml
    ports:
      - "4317:4317"   # OTLP gRPC
      - "4318:4318"   # OTLP HTTP
      - "8889:8889"   # Prometheus メトリクス

  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"  # Jaeger UI

  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
```

---

## 自動計装（コードを変えずに計装する）

多くのフレームワーク・ライブラリは自動計装エージェントで対応できる。

```bash
# Python: opentelemetry-instrument コマンドで起動するだけ
opentelemetry-instrument \
  --traces_exporter otlp \
  --metrics_exporter otlp \
  --exporter_otlp_endpoint http://otel-collector:4317 \
  python app.py
```

```yaml
# Kubernetes: sidecar パターン（アプリを変更せずに計装）
# Java エージェントをサイドカーで注入する例
initContainers:
  - name: otel-agent
    image: ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:latest
    command: ["cp", "-r", "/javaagent.jar", "/otel-agent/"]
    volumeMounts:
      - name: otel-agent
        mountPath: /otel-agent
```

---

## Grafana でトレース・メトリクス・ログを横断する

Grafana はデータソースとして Jaeger/Tempo（トレース）・Prometheus（メトリクス）・Loki（ログ）を同時に使える。

**Exemplars（メトリクス → トレースへのリンク）:**
メトリクスグラフの特定の点をクリックすると、その時刻のトレースに飛べる機能。「レイテンシのスパイクが起きたリクエストのトレース」を一発で見られる。

```yaml
# Prometheus でメトリクスに trace_id を付ける
- job_name: 'myapp'
  scrape_interval: 15s
  static_configs:
    - targets: ['myapp:8080']
  # Exemplar のサポートを有効化
```

---

## OpenTelemetry を導入するかどうかの判断

| 状況 | 判断 |
|---|---|
| モノリス + 1サービス | 通常の Prometheus + ログで十分 |
| マイクロサービス 3つ以上 | OTel の導入価値が出始める |
| 「どのサービスが遅いか」がわからない | 今すぐ OTel を導入する |
| ベンダーロックインを避けたい | OTel 一択 |

最初から完璧に構築しようとせず、**まずトレースだけ** 入れて、慣れたらメトリクス・ログも OTel に統合していくのが現実的。
