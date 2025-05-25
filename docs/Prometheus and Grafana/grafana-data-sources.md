# Grafana データソース設定ガイド

Grafanaは、様々なデータソースからデータを取得して可視化することができます。このガイドでは、主なデータソースの設定方法について説明します。

## データソースの追加方法

1. Grafanaにログイン後、左側のメニューから「Configuration」（⚙️）をクリック
2. 「Data sources」を選択
3. 「Add data source」ボタンをクリック

## 主要なデータソース

### Prometheus

Prometheusは、Grafanaで最も一般的に使用されるデータソースの1つです。

#### 設定手順

1. データソース一覧から「Prometheus」を選択
2. 以下の設定を行います：

```
Name: Prometheus
URL: http://localhost:9090
Access: Server (default)
```

#### 追加設定（オプション）

- **Scrape interval**: データの取得間隔（デフォルト: 15s）
- **Query timeout**: クエリのタイムアウト時間
- **HTTP Method**: GET（デフォルト）または POST

### Node Exporter

Node Exporterのメトリクスは、Prometheusを経由してGrafanaで表示できます。特別なデータソース設定は必要ありません。

### その他の一般的なデータソース

#### InfluxDB

```
Name: InfluxDB
URL: http://localhost:8086
Access: Server
Database: your_database
User: your_username
Password: your_password
```

#### MySQL

```
Name: MySQL
Host: localhost:3306
Database: your_database
User: your_username
Password: your_password
```

#### PostgreSQL

```
Name: PostgreSQL
Host: localhost:5432
Database: your_database
User: your_username
Password: your_password
```

## データソースの設定項目

### 共通設定

- **Name**: データソースの表示名
- **Default**: デフォルトのデータソースとして設定するかどうか
- **Access**: データソースへのアクセス方法
  - Server: Grafanaサーバーからアクセス
  - Browser: ブラウザから直接アクセス

### 認証設定

- **Basic Auth**: 基本認証の有効/無効
- **User**: 認証ユーザー名
- **Password**: 認証パスワード
- **TLS/SSL**: セキュア接続の設定

### プロキシ設定

- **Proxy**: プロキシの使用有無
- **Timeout**: リクエストのタイムアウト時間

## データソースの管理

### データソースの編集

1. データソース一覧から編集したいデータソースを選択
2. 「Edit」ボタンをクリック
3. 必要な設定を変更
4. 「Save & Test」をクリックして設定を保存

### データソースの削除

1. データソース一覧から削除したいデータソースを選択
2. 「Delete」ボタンをクリック
3. 確認ダイアログで「Delete」をクリック

## 注意事項

- データソースの設定は、Grafanaの設定ファイル（grafana.ini）でも管理できます
- 本番環境では、適切な認証設定とセキュリティ設定を行うことをお勧めします
- データソースの接続テストは、設定保存前に必ず行ってください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/datasources/)を参照してください 
