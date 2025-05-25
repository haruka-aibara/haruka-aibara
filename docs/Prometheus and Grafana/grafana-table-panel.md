# Grafana Tableパネルガイド

GrafanaのTableパネルは、データを表形式で表示するためのパネルです。メトリクスの一覧表示やログデータの表示などに適しています。このガイドでは、Tableパネルの設定と使用方法について説明します。

## Tableパネルの基本

### パネルの作成

1. **新規パネルの追加**
   - ダッシュボードの編集画面を開く
   - 「Add panel」をクリック
   - 「Table」を選択

2. **データソースの設定**
   ```promql
   # 例：CPU使用率の一覧
   topk(10, rate(node_cpu_seconds_total{mode="idle"}[5m]))
   
   # 例：メモリ使用量の一覧
   topk(10, node_memory_MemTotal_bytes - node_memory_MemFree_bytes)
   ```

### 表示設定

1. **基本設定**
   - タイトル
   - 説明
   - 表示行数
   - ページネーション

2. **テーブルの外観**
   - 列の表示/非表示
   - 列の順序
   - ソート設定
   - フィルター設定

## 詳細設定

### 列の設定

1. **列のカスタマイズ**
   ```yaml
   # 列の設定例
   Columns:
     - field: instance
       title: インスタンス
       width: 200
     - field: value
       title: 使用率
       unit: percent
       decimals: 2
   ```

2. **列の表示形式**
   - 数値のフォーマット
   - 単位の表示
   - 色の設定
   - リンクの設定

### フィルターとソート

1. **フィルター設定**
   - 列ごとのフィルター
   - 検索機能
   - 条件フィルター

2. **ソート設定**
   - 昇順/降順
   - 複数列でのソート
   - デフォルトのソート順

## 実践的な設定例

### システムメトリクスの表示

```yaml
# パネル設定
Title: System Metrics
Query: 
  - node_cpu_seconds_total
  - node_memory_MemTotal_bytes
  - node_filesystem_size_bytes
Columns:
  - instance
  - metric
  - value
Transformations:
  - Organize fields
  - Calculate new fields
Display:
  - Pagination: 10 rows per page
  - Show header
  - Enable filtering
```

### アラート履歴の表示

```yaml
# パネル設定
Title: Alert History
Query: ALERTS{alertstate="firing"}
Columns:
  - alertname
  - instance
  - severity
  - startTime
  - endTime
Transformations:
  - Filter by name
  - Sort by time
Display:
  - Pagination: 20 rows per page
  - Enable search
  - Show timestamps
```

## 高度な設定

### データの変換

1. **フィールドの変換**
   - 計算フィールドの追加
   - 単位の変換
   - 日時のフォーマット

2. **データの集計**
   - グループ化
   - 合計値の計算
   - 平均値の計算

### インタラクティブ機能

1. **クリックイベント**
   - 行のクリック
   - 列のクリック
   - リンクの設定

2. **動的フィルター**
   - ダッシュボード変数との連携
   - 時間範囲によるフィルター
   - 条件によるフィルター

## 注意事項

- 表示するデータ量を考慮してください
- パフォーマンスに影響を与えないよう注意してください
- 適切なページネーションを設定してください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/panels/visualizations/table/)を参照してください 
