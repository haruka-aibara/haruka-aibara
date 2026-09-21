# Grafana サービスアカウントガイド

Grafanaのサービスアカウントは、APIや自動化スクリプトからGrafanaにアクセスするための特別なアカウントです。このガイドでは、サービスアカウントの作成、管理、使用方法について説明します。

## サービスアカウントの基本

### サービスアカウントの作成

1. **新規作成**
   - 管理画面の「Service accounts」を開く
   - 「New service account」をクリック
   - 必要な情報を入力
     - アカウント名
     - 説明
     - 権限レベル

2. **APIキーの生成**
   - サービスアカウント作成後
   - 「Add API key」をクリック
   - キーの名前と有効期限を設定
   - 生成されたキーを安全に保管

### 権限レベル

1. **Viewer（閲覧者）**
   - ダッシュボードの閲覧
   - メトリクスの取得
   - 設定の参照

2. **Editor（編集者）**
   - ダッシュボードの作成・編集
   - アラートの設定
   - データの更新

3. **Admin（管理者）**
   - すべての機能にアクセス
   - システム設定の変更
   - ユーザー管理

## サービスアカウントの管理

### APIキーの管理

1. **キーの作成**
   ```yaml
   # APIキーの作成例
   Name: automation-script
   Role: Editor
   Expiration: 30 days
   ```

2. **キーの更新**
   - 古いキーの無効化
   - 新しいキーの生成
   - クライアント側の更新

### アクセス制御

1. **IP制限**
   - 許可するIPアドレスの設定
   - アクセス時間の制限
   - 地域による制限

2. **トークンの有効期限**
   - 短期間のトークン
   - 長期間のトークン
   - 自動更新の設定

## 使用例

### APIアクセス

1. **ダッシュボードの操作**
   ```bash
   # ダッシュボードの取得
   curl -H "Authorization: Bearer $API_KEY" \
     http://your-grafana/api/dashboards/uid/your-dashboard
   ```

2. **アラートの管理**
   ```bash
   # アラートの作成
   curl -X POST \
     -H "Authorization: Bearer $API_KEY" \
     -H "Content-Type: application/json" \
     -d @alert.json \
     http://your-grafana/api/alerts
   ```

### 自動化スクリプト

1. **バックアップの自動化**
   ```python
   # ダッシュボードのバックアップ
   import requests
   
   headers = {
       'Authorization': f'Bearer {api_key}',
       'Content-Type': 'application/json'
   }
   
   response = requests.get(
       'http://your-grafana/api/dashboards/uid/your-dashboard',
       headers=headers
   )
   ```

2. **監視の自動化**
   ```python
   # メトリクスの取得
   response = requests.get(
       'http://your-grafana/api/datasources/proxy/1/api/v1/query',
       params={'query': 'your_metric'},
       headers=headers
   )
   ```

## セキュリティのベストプラクティス

### キーの管理

1. **安全な保管**
   - 環境変数での管理
   - シークレット管理ツールの使用
   - 定期的なローテーション

2. **アクセス制限**
   - 必要最小限の権限
   - 定期的な権限の見直し
   - 使用状況の監視

### 監査とログ

1. **アクセスログ**
   - APIリクエストの記録
   - エラーの監視
   - 異常なアクセスの検知

2. **定期的なレビュー**
   - 使用状況の確認
   - 不要なキーの削除
   - 権限の見直し

## 注意事項

- APIキーは安全に保管してください
- 必要最小限の権限を設定してください
- 定期的なキーのローテーションを行ってください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/administration/service-accounts/)を参照してください 
