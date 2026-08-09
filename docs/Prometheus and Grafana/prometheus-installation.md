# Prometheus インストールガイド

Prometheusは、オープンソースのモニタリングシステムです。このガイドでは、Prometheusのインストール方法について説明します。

## インストール手順

### バイナリからのインストール（推奨）

1. 最新のバイナリをダウンロードします：

```bash
# 最新バージョンのダウンロード（例：2.45.0）
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# アーカイブの展開
tar xvfz prometheus-*.tar.gz
cd prometheus-*
```

2. 設定ファイルの作成：

```bash
# 設定ファイルの作成
cat > prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
```

3. Prometheusの起動：

```bash
# 直接起動
./prometheus --config.file=prometheus.yml

# または、systemdサービスとして設定
sudo mv prometheus /usr/local/bin/
sudo mv prometheus.yml /etc/prometheus/
```

### systemdサービスの設定

```bash
sudo cat > /etc/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# サービスの起動
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

## アクセス方法

Prometheusはデフォルトでポート9090で起動します。ブラウザで以下のURLにアクセスしてください：

```
http://localhost:9090
```

## 注意事項

- ファイアウォールを使用している場合は、ポート9090を開放する必要があります
- 本番環境では、セキュリティ設定を適切に行ってください
- 詳細な設定や使用方法については、[公式ドキュメント](https://prometheus.io/docs/introduction/overview/)を参照してください 
