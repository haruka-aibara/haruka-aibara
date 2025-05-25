# Grafana インストールガイド

Grafanaは、メトリクスやログの可視化に使用される人気のオープンソースツールです。このガイドでは、Grafanaのインストール方法について説明します。

## インストール手順

### Ubuntu/Debian の場合

```bash
# 必要なパッケージのインストール
sudo apt-get install -y adduser libfontconfig1 musl

# Grafanaのダウンロードとインストール
wget https://dl.grafana.com/enterprise/release/grafana-enterprise_12.0.1_amd64.deb
sudo dpkg -i grafana-enterprise_12.0.1_amd64.deb
```

### Red Hat/CentOS/RHEL/Fedora の場合

```bash
sudo yum install -y https://dl.grafana.com/enterprise/release/grafana-enterprise-12.0.1-1.x86_64.rpm
```

### OpenSUSE/SUSE の場合

```bash
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-12.0.1-1.x86_64.rpm
sudo rpm -Uvh grafana-enterprise-12.0.1-1.x86_64.rpm
```

## Grafanaの起動

インストール後、以下のコマンドでGrafanaを起動できます：

```bash
# サービスの起動
sudo systemctl start grafana-server

# システム起動時に自動起動するように設定
sudo systemctl enable grafana-server
```

## アクセス方法

Grafanaはデフォルトでポート3000で起動します。ブラウザで以下のURLにアクセスしてください：

```
http://localhost:3000
```

デフォルトのログイン情報：
- ユーザー名: admin
- パスワード: admin

初回ログイン時にパスワードの変更を求められます。

## 注意事項

- ファイアウォールを使用している場合は、ポート3000を開放する必要があります
- 本番環境では、必ずデフォルトのパスワードを変更してください
- 必要に応じて、`/etc/grafana/grafana.ini`で設定を変更できます 
