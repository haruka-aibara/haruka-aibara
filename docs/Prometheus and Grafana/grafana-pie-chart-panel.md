# Grafana Pie Chartパネルガイド

GrafanaのPie Chartパネルは、データを円グラフで表示するためのパネルです。割合や分布を視覚的に表示するのに適しています。このガイドでは、Pie Chartパネルの設定と使用方法について説明します。

## Pie Chartパネルの基本

### パネルの作成

1. **新規パネルの追加**
   - ダッシュボードの編集画面を開く
   - 「Add panel」をクリック
   - 「Pie chart」を選択

2. **データソースの設定**
   ```promql
   # 例：CPU使用率の分布
   sum by (mode) (rate(node_cpu_seconds_total[5m]))
   
   # 例：メモリ使用量の分布
   sum by (type) (node_memory_MemTotal_bytes)
   ```

### 表示設定

1. **基本設定**
   - タイトル
   - 説明
   - 表示モード
   - 凡例の設定

2. **グラフの外観**
   - 円グラフのスタイル
   - 色の設定
   - ラベルの表示
   - 値の表示

## 詳細設定

### データの表示設定

1. **値のフォーマット**
   ```yaml
   # 表示設定の例
   Display:
     mode: pie
     valueFormat: percent
     decimals: 2
     showLegend: true
     legendPosition: right
   ```

2. **表示オプション**
   - パーセンテージ表示
   - 絶対値表示
   - カスタムフォーマット
   - 単位の設定

### 色とスタイル

1. **色の設定**
   ```yaml
   # 色の設定例
   Colors:
     - mode: palette
       palette: default
     - mode: threshold
       thresholds:
         - value: 50
           color: yellow
         - value: 80
           color: red
   ```

2. **スタイル設定**
   - 円グラフの種類
   - ドーナツグラフ
   - ラベルの位置
   - アニメーション

## 実践的な設定例

### システムリソースの分布

```yaml
# パネル設定
Title: System Resource Distribution
Query: 
  - name: CPU Usage
    query: sum by (mode) (rate(node_cpu_seconds_total[5m]))
    legend: {{mode}}
  - name: Memory Usage
    query: sum by (type) (node_memory_MemTotal_bytes)
    legend: {{type}}
Display:
  mode: pie
  valueFormat: percent
  showLegend: true
  legendPosition: right
```

### アプリケーション統計の分布

```yaml
# パネル設定
Title: Application Statistics
Query: 
  - name: Request Types
    query: sum by (type) (http_requests_total)
    legend: {{type}}
  - name: Error Distribution
    query: sum by (error_type) (http_errors_total)
    legend: {{error_type}}
Display:
  mode: donut
  valueFormat: number
  showLegend: true
  legendPosition: bottom
```

## 高度な設定

### データの変換

1. **値の計算**
   - 合計値の計算
   - 平均値の計算
   - パーセンテージの計算
   - カスタム計算

2. **データのフィルタリング**
   - しきい値によるフィルター
   - ラベルによるフィルター
   - 時間範囲によるフィルター
   - カスタムフィルター

### インタラクティブ機能

1. **クリックイベント**
   - セグメントのクリック
   - 詳細情報の表示
   - リンクの設定

2. **ツールチップ**
   - 詳細情報の表示
   - 補足説明の追加
   - 関連データの表示

## 注意事項

- 表示するデータの種類を考慮してください
   - 割合や分布の表示に適しています
   - 時系列データには適していません
- セグメント数が多すぎないようにしてください
- 色の選択は視認性を考慮してください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/panels/visualizations/pie-chart/)を参照してください 
