# Node Exporter インストールガイド

Node Exporterは、LinuxシステムのハードウェアとOSのメトリクスを収集するためのPrometheusのエクスポーターです。

## インストール手順

### バイナリからのインストール（推奨）

1. 最新のバイナリをダウンロードします：

```bash
# 最新バージョンのダウンロード（例：1.7.0）
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz

# アーカイブの展開
tar xvfz node_exporter-*.tar.gz
cd node_exporter-*
```

2. Node Exporterの起動：

```bash
# 直接起動
./node_exporter

# または、systemdサービスとして設定
sudo mv node_exporter /usr/local/bin/
```

### systemdサービスの設定

```bash
sudo cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# サービスの起動
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

## Prometheusの設定

Node Exporterのメトリクスを収集するために、Prometheusの設定ファイル（prometheus.yml）に以下を追加します：

```yaml
scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
```

## アクセス方法

Node Exporterはデフォルトでポート9100で起動します。メトリクスは以下のURLで確認できます：

```
http://localhost:9100/metrics
```

## 注意事項

- ファイアウォールを使用している場合は、ポート9100を開放する必要があります
- 本番環境では、セキュリティ設定を適切に行ってください
- 詳細な設定や使用方法については、[公式ドキュメント](https://prometheus.io/docs/guides/node-exporter/)を参照してください 
