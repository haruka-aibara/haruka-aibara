# Grafana ダッシュボードのJSONエクスポートガイド

Grafanaのダッシュボードは、JSON形式でエクスポートすることができます。この機能は、ダッシュボードのバックアップ、共有、移行に非常に便利です。このガイドでは、JSONエクスポートの方法と活用方法について説明します。

## エクスポートの基本

### エクスポート方法

1. **個別のダッシュボード**
   - ダッシュボードを開く
   - 右上の「Share」ボタンをクリック
   - 「Export」タブを選択
   - 「Save to file」をクリック
   - JSONファイルがダウンロードされる

2. **複数のダッシュボード**
   - ダッシュボード一覧画面を開く
   - エクスポートしたいダッシュボードを選択
   - 「Export」ボタンをクリック
   - 選択したダッシュボードのJSONがダウンロードされる

### エクスポートされる情報

```json
{
  "annotations": {
    "list": []
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "id": null,
  "links": [],
  "liveNow": false,
  "panels": [],
  "refresh": "5s",
  "schemaVersion": 38,
  "style": "dark",
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "",
  "title": "ダッシュボード名",
  "uid": "",
  "version": 1,
  "weekStart": ""
}
```

## エクスポートの活用

### バックアップ

1. **定期的なバックアップ**
   - 重要なダッシュボードの定期的なエクスポート
   - バックアップファイルの安全な保管
   - バックアップの履歴管理

2. **バックアップの自動化**
   - APIを使用した自動エクスポート
   - スクリプトによる定期実行
   - バックアップの検証

### 共有と移行

1. **チーム間での共有**
   - JSONファイルの共有
   - インポート手順の提供
   - 設定の説明

2. **環境間の移行**
   - 開発環境から本番環境への移行
   - データソースの設定変更
   - 変数の調整

## インポート方法

### 基本的なインポート

1. **UIからのインポート**
   - 「+」ボタンをクリック
   - 「Import」を選択
   - JSONファイルをアップロード
   - 必要に応じて設定を調整
   - 「Import」をクリック

2. **APIを使用したインポート**
   ```bash
   curl -X POST \
     -H "Content-Type: application/json" \
     -d @dashboard.json \
     http://your-grafana/api/dashboards/db
   ```

## 注意事項

- エクスポート前にデータソースの設定を確認してください
- 機密情報が含まれていないか確認してください
- インポート時にデータソースの設定を適切に行ってください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/dashboards/export-import/)を参照してください 
