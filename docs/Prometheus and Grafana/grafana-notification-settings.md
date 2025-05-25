# Grafana 通知設定ガイド

Grafanaの通知設定は、アラートの発生時に適切なチャネルを通じて通知を送信するための重要な機能です。このガイドでは、Contact PointsとNotification Policiesの設定方法について説明します。

## Contact Points（通知先）の設定

### メール通知の設定

1. **SMTPサーバーの設定**
   ```yaml
   # grafana.ini
   [smtp]
   enabled = true
   host = smtp.gmail.com:587
   user = your-email@gmail.com
   password = your-app-password
   from_address = your-email@gmail.com
   from_name = Grafana Alert
   startTLS_policy = MandatoryStartTLS
   ```

2. **Contact Pointの作成**
   - Alerting > Contact points > New contact point
   - 名前: "Email Alerts"
   - タイプ: Email
   - 設定:
     - 送信先メールアドレス
     - 件名テンプレート
     - メッセージテンプレート

### Slack通知の設定

1. **Slackアプリの設定**
   - Slack APIで新しいアプリを作成
   - Incoming Webhookを有効化
   - Webhook URLを取得

2. **Contact Pointの作成**
   - Alerting > Contact points > New contact point
   - 名前: "Slack Alerts"
   - タイプ: Slack
   - 設定:
     - Webhook URL
     - チャンネル名
     - メッセージテンプレート

### その他の通知チャネル

1. **Discord**
   - Webhook URLを使用
   - チャンネル設定
   - メッセージフォーマット

2. **Teams**
   - Webhook URLを使用
   - カードテンプレート
   - アクションボタン

3. **Webhook**
   - カスタムエンドポイント
   - ヘッダー設定
   - ペイロードテンプレート

## Notification Policies（通知ポリシー）の設定

### 基本ポリシーの設定

1. **デフォルトポリシー**
   ```yaml
   # デフォルトポリシーの例
   - name: Default Policy
     contact_point: Email Alerts
     group_by: ['alertname', 'instance']
     group_wait: 30s
     group_interval: 5m
     repeat_interval: 4h
     routes:
       - match:
           severity: critical
         contact_point: Slack Alerts
   ```

2. **ルーティングルール**
   - アラートの重要度による分岐
   - 時間帯による分岐
   - ラベルによる分岐

### 高度なポリシー設定

1. **グループ化設定**
   ```yaml
   # グループ化の例
   group_by:
     - alertname
     - instance
     - severity
   group_wait: 30s
   group_interval: 5m
   repeat_interval: 4h
   ```

2. **タイミング設定**
   - グループ待機時間
   - グループ間隔
   - 繰り返し間隔
   - 時間帯制限

## 通知テンプレート

### メールテンプレート

```yaml
# メールテンプレートの例
subject: {{ .GroupLabels.alertname }} - {{ .Status }}
message: |
  Alert: {{ .GroupLabels.alertname }}
  Status: {{ .Status }}
  Severity: {{ .CommonLabels.severity }}
  Instance: {{ .CommonLabels.instance }}
  
  {{ range .Alerts }}
  Description: {{ .Annotations.description }}
  Value: {{ .Annotations.value }}
  {{ end }}
```

### Slackテンプレート

```yaml
# Slackテンプレートの例
blocks:
  - type: section
    text:
      type: mrkdwn
      text: |
        *Alert: {{ .GroupLabels.alertname }}*
        Status: {{ .Status }}
        Severity: {{ .CommonLabels.severity }}
        
        {{ range .Alerts }}
        • {{ .Annotations.description }}
        {{ end }}
```

## 実践的な設定例

### 本番環境の通知設定

```yaml
# 本番環境の通知ポリシー
- name: Production Alerts
  contact_point: Slack Alerts
  group_by: ['alertname', 'instance']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  routes:
    - match:
        severity: critical
      contact_point: Email Alerts
      group_wait: 0s
      repeat_interval: 30m
    - match:
        severity: warning
      contact_point: Slack Alerts
      group_wait: 1m
      repeat_interval: 4h
```

### 開発環境の通知設定

```yaml
# 開発環境の通知ポリシー
- name: Development Alerts
  contact_point: Slack Alerts
  group_by: ['alertname']
  group_wait: 1m
  group_interval: 10m
  repeat_interval: 4h
  routes:
    - match:
        severity: critical
      contact_point: Email Alerts
      group_wait: 0s
      repeat_interval: 1h
```

## 注意事項

- 通知の頻度を適切に設定してください
- 重要なアラートは複数のチャネルで通知することを検討してください
- テンプレートは環境に合わせてカスタマイズしてください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/alerting/notifications/)を参照してください 
