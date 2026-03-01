# OpenTelemetry

## 問題

メトリクスは Prometheus、ログは Loki、トレースは Jaeger と、可観測性ツールごとに別々の SDK やエージェントを使う必要がある。ツールを切り替えたいときにアプリケーションコードを書き直さなければならない。

OpenTelemetry（OTel）は**メトリクス・ログ・トレースを統一した標準**。アプリにベンダー中立な形で計装（Instrumentation）しておけば、バックエンドを後から自由に選べる。

---

## 3つのシグナル

| シグナル | 何を知れるか | 例 |
|---------|------------|---|
| メトリクス | 「今どんな状態か」数値での状況把握 | リクエスト数、エラー率、レイテンシ |
| ログ | 「何が起きたか」イベントの記録 | エラーメッセージ、リクエスト詳細 |
| トレース | 「どこで時間がかかっているか」処理の流れ | API → DB → 外部サービスの連鎖 |

この3つをまとめて **Observability の3本柱** という。

---

## アーキテクチャ

```
アプリケーション
  └── OTel SDK（計装）
        ↓
OpenTelemetry Collector（収集・変換・転送）
        ├── Prometheus（メトリクス）
        ├── Loki（ログ）
        └── Jaeger / Tempo（トレース）
```

**OTel Collector** を間に挟むのがポイント。アプリは Collector にだけ送れば良く、バックエンドを変えてもアプリコードに影響しない。

---

## 分散トレーシングの仕組み

マイクロサービスをまたぐリクエストの流れを可視化する。

```
ユーザーリクエスト
  └── Trace ID: abc123
        ├── Span: API Gateway (10ms)
        ├── Span: Auth Service (5ms)
        ├── Span: User Service (30ms)
        │     └── Span: DB Query (25ms)  ← ここがボトルネック
        └── Span: Response (2ms)
```

各サービスが同じ Trace ID を HTTP ヘッダー（`traceparent`）で伝搬させることで、サービスをまたいだ全体の処理フローが1つのトレースとして表示される。

---

## Python での計装例

```python
# pip install opentelemetry-api opentelemetry-sdk
# pip install opentelemetry-instrumentation-fastapi
# pip install opentelemetry-exporter-otlp

from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Tracer の初期化（アプリ起動時に一度だけ）
provider = TracerProvider()
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="http://otel-collector:4317"))
)
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

# コード内でスパンを作る
def process_order(order_id: str):
    with tracer.start_as_current_span("process_order") as span:
        span.set_attribute("order.id", order_id)
        # 処理...
        span.set_attribute("order.status", "processed")
```

FastAPI・Flask・Django・requests など主要なライブラリは**自動計装**があるので、コードを1行も変えずにトレースを取れる。

```python
# 自動計装（FastAPI の場合）
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
FastAPIInstrumentor.instrument_app(app)
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

exporters:
  prometheus:
    endpoint: "0.0.0.0:8889"
  loki:
    endpoint: http://loki:3100/loki/api/v1/push
  jaeger:
    endpoint: jaeger:14250

service:
  pipelines:
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [prometheus]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [loki]
    traces:
      receivers: [otlp]
      processors: [batch]
      exporters: [jaeger]
```

---

## AWS での活用

AWS Distro for OpenTelemetry（ADOT）は AWS が管理する OTel ディストリビューション。

- **ECS / EKS**: ADOT Collector をサイドカーとして配置
- **Lambda**: ADOT Lambda レイヤーを追加するだけで自動計装
- **X-Ray**: OTel のトレースを AWS X-Ray に転送できる

既存の X-Ray SDK から移行する場合も、OTel → X-Ray エクスポーターがあるので段階的に移行できる。

---

## まとめ

- **計装は OTel SDK で一度だけ** → バックエンドを変えてもアプリコードは変えなくていい
- **OTel Collector が中継点** → フィルタリング・変換・複数バックエンドへの転送を担う
- **自動計装から始める** → まず既存コードを変えずにトレースを取って、必要に応じてカスタムスパンを追加
