# Blackbox Exporter Webサイト監視ガイド

Blackbox Exporterは、HTTP、HTTPS、DNS、TCP、ICMPなどのプロトコルを使用してエンドポイントの可用性を監視するためのPrometheusエクスポーターです。このガイドでは、Webサイトのステータス監視の設定方法について説明します。

## Blackbox Exporterの基本設定

### インストールと設定

1. **Blackbox Exporterのインストール**
   ```bash
   # 最新バージョンのダウンロード
   wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.24.0/blackbox_exporter-0.24.0.linux-amd64.tar.gz
   
   # アーカイブの展開
   tar xvfz blackbox_exporter-0.24.0.linux-amd64.tar.gz
   
   # 実行ファイルの移動
   sudo mv blackbox_exporter-0.24.0.linux-amd64/blackbox_exporter /usr/local/bin/
   ```

2. **設定ファイルの作成**
   ```yaml
   # /etc/blackbox_exporter/config.yml
   modules:
     http_2xx:
       prober: http
       timeout: 5s
       http:
         method: GET
         preferred_ip_protocol: "ip4"
         valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
         valid_status_codes: [200, 204, 301, 302, 307, 308]
         fail_if_ssl: false
         fail_if_not_ssl: false
         tls_config:
           insecure_skip_verify: true
         headers:
           User-Agent: "Prometheus/Blackbox Exporter"
   ```

3. **サービスの起動**
   ```bash
   # systemdサービスの作成
   sudo nano /etc/systemd/system/blackbox_exporter.service
   
   [Unit]
   Description=Blackbox Exporter
   After=network-online.target
   
   [Service]
   Type=simple
   User=blackbox_exporter
   ExecStart=/usr/local/bin/blackbox_exporter --config.file=/etc/blackbox_exporter/config.yml
   
   [Install]
   WantedBy=multi-user.target
   
   # サービスの起動
   sudo systemctl start blackbox_exporter
   sudo systemctl enable blackbox_exporter
   ```

## Prometheusの設定

### ターゲットの設定

1. **Prometheus設定の追加**
   ```yaml
   # /etc/prometheus/prometheus.yml
   scrape_configs:
     - job_name: 'blackbox'
       metrics_path: /probe
       params:
         module: [http_2xx]
       static_configs:
         - targets:
           - https://example.com
           - https://example.org
       relabel_configs:
         - source_labels: [__address__]
           target_label: __param_target
         - source_labels: [__param_target]
           target_label: instance
         - target_label: __address__
           replacement: localhost:9115
   ```

2. **動的ターゲットの設定**
   ```yaml
   # ファイルベースのサービスディスカバリ
   - job_name: 'blackbox'
     file_sd_configs:
       - files:
         - 'targets/websites.yml'
     metrics_path: /probe
     params:
       module: [http_2xx]
     relabel_configs:
       - source_labels: [__address__]
         target_label: __param_target
       - source_labels: [__param_target]
         target_label: instance
       - target_label: __address__
         replacement: localhost:9115
   ```

## 監視メトリクス

### 基本的なメトリクス

1. **可用性の監視**
   ```promql
   # サイトの可用性
   probe_success{instance="https://example.com"}
   
   # レスポンスタイム
   probe_duration_seconds{instance="https://example.com"}
   
   # HTTPステータスコード
   probe_http_status_code{instance="https://example.com"}
   ```

2. **SSL証明書の監視**
   ```promql
   # SSL証明書の有効期限
   probe_ssl_earliest_cert_expiry{instance="https://example.com"}
   
   # SSL証明書の検証結果
   probe_ssl_verify_result{instance="https://example.com"}
   ```

## アラート設定

### 基本的なアラート

```yaml
# /etc/prometheus/rules/blackbox_alerts.yml
groups:
  - name: blackbox
    rules:
      - alert: WebsiteDown
        expr: probe_success{job="blackbox"} == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Website {{ $labels.instance }} is down"
          description: "Website has been down for more than 5 minutes"

      - alert: HighResponseTime
        expr: probe_duration_seconds{job="blackbox"} > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High response time on {{ $labels.instance }}"
          description: "Response time is above 2 seconds"

      - alert: SSLCertExpiring
        expr: probe_ssl_earliest_cert_expiry{job="blackbox"} - time() < 86400 * 30
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "SSL certificate for {{ $labels.instance }} is expiring soon"
          description: "SSL certificate will expire in 30 days"
```

## Grafanaダッシュボード

### 基本的なダッシュボード設定

```yaml
# ダッシュボード設定
Panels:
  - title: Website Status
    type: stat
    queries:
      - probe_success{instance="$instance"}
    thresholds:
      - 0 (critical)
      - 1 (ok)

  - title: Response Time
    type: graph
    queries:
      - probe_duration_seconds{instance="$instance"}
    thresholds:
      - 1 (warning)
      - 2 (critical)

  - title: SSL Certificate Expiry
    type: gauge
    queries:
      - (probe_ssl_earliest_cert_expiry{instance="$instance"} - time()) / 86400
    thresholds:
      - 30 (warning)
      - 7 (critical)
```

## 注意事項

- 監視対象のWebサイトの負荷を考慮してください
- 適切な監視間隔を設定してください
- アラートのしきい値は環境に応じて調整してください
- より詳細な設定や使用方法については、[公式ドキュメント](https://github.com/prometheus/blackbox_exporter)を参照してください 
