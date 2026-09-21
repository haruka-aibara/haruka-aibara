# Grafana 凡例（Legend）カスタマイズガイド

Grafanaの凡例（Legend）は、グラフやパネルに表示されるデータ系列の説明を表示する部分です。このガイドでは、凡例のカスタマイズ方法について説明します。

## 凡例の基本設定

### 凡例の表示設定

1. **凡例の表示/非表示**
   - パネルの編集画面を開く
   - 「Panel options」を選択
   - 「Legend」セクションで表示/非表示を切り替え

2. **凡例の位置**
   ```yaml
   # 凡例の位置設定
   Legend:
     showLegend: true
     displayMode: list  # list, table
     placement: bottom  # bottom, right
     width: 200
     height: 100
   ```

### 凡例の表示モード

1. **リストモード**
   - シンプルなリスト表示
   - 値の表示/非表示
   - 色の表示
   - 系列名の表示

2. **テーブルモード**
   - 表形式での表示
   - 列のカスタマイズ
   - ソート機能
   - フィルター機能

## 凡例のカスタマイズ

### 系列名のカスタマイズ

1. **ラベルの設定**
   ```yaml
   # ラベル設定の例
   Legend:
     labelFormat: {{instance}} - {{job}}
     valueFormat: {{value}}%
     hideEmpty: true
     hideZero: true
   ```

2. **表示形式の設定**
   - 変数の使用
   - 正規表現の使用
   - 条件付き表示
   - カスタムフォーマット

### 値の表示設定

1. **値のフォーマット**
   ```yaml
   # 値の表示設定
   Legend:
     showValues: true
     valuesFormat: short
     decimals: 2
     unit: percent
   ```

2. **表示オプション**
   - 現在値
   - 最小値
   - 最大値
   - 平均値
   - 合計値

## 実践的な設定例

### システムメトリクスの凡例

```yaml
# 凡例設定
Legend:
  showLegend: true
  displayMode: table
  placement: bottom
  labelFormat: {{instance}} - {{metric}}
  valuesFormat: short
  columns:
    - min
    - max
    - avg
    - current
  sortBy: current
  sortDesc: true
```

### アプリケーション統計の凡例

```yaml
# 凡例設定
Legend:
  showLegend: true
  displayMode: list
  placement: right
  labelFormat: {{service}} - {{endpoint}}
  valuesFormat: percent
  showValues: true
  hideEmpty: true
  hideZero: true
```

## 高度な設定

### 条件付き表示

1. **表示条件**
   - 値に基づく表示/非表示
   - 時間範囲に基づく表示
   - カスタム条件

2. **スタイル設定**
   - フォントサイズ
   - 色の設定
   - 背景色
   - 枠線

### インタラクティブ機能

1. **クリックイベント**
   - 系列の表示/非表示
   - 詳細情報の表示
   - リンクの設定

2. **ツールチップ**
   - 詳細情報の表示
   - 補足説明の追加
   - 関連データの表示

## 注意事項

- 凡例の表示はデータの可読性に影響します
- 適切な表示モードを選択してください
- 必要に応じて凡例を非表示にしてください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/panels/visualizations/legend/)を参照してください 
