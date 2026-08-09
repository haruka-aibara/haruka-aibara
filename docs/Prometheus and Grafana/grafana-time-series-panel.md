# Grafana Time Series パネルガイド

Time Seriesパネルは、Grafanaで最も一般的に使用される可視化パネルの1つです。時系列データをグラフとして表示し、データの傾向やパターンを分析するのに適しています。

## 基本的な使い方

### パネルの追加

1. ダッシュボードで「Add panel」をクリック
2. 「Time series」を選択

### クエリの設定

#### Prometheusの場合

```promql
# CPU使用率の例
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# メモリ使用率の例
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100
```

## パネルの設定

### 表示設定

#### グラフの種類

- **Lines**: 折れ線グラフ（デフォルト）
- **Bars**: 棒グラフ
- **Points**: 点グラフ
- **Area**: エリアグラフ

#### スタイル設定

- **Line width**: 線の太さ
- **Fill opacity**: 塗りつぶしの透明度
- **Gradient mode**: グラデーションの種類
  - None: グラデーションなし
  - Opacity: 透明度によるグラデーション
  - Hue: 色相によるグラデーション

### 軸の設定

#### Y軸

- **Unit**: 単位の設定（例：percent、bytes、seconds）
- **Scale**: スケールの種類
  - Linear: 線形スケール
  - Logarithmic: 対数スケール
- **Min**: 最小値
- **Max**: 最大値
- **Decimals**: 小数点以下の桁数

#### X軸

- **Mode**: 表示モード
  - Time: 時間軸
  - Series: シリーズ軸
- **Placement**: 軸の位置
  - Bottom: 下部
  - Top: 上部

### 凡例の設定

- **Show legend**: 凡例の表示/非表示
- **Display mode**: 凡例の表示モード
  - List: リスト形式
  - Table: テーブル形式
- **Placement**: 凡例の位置
  - Bottom: 下部
  - Right: 右側

### ツールチップの設定

- **Mode**: ツールチップの表示モード
  - Single: 単一の値
  - All: すべての値
- **Sort order**: 値の並び順
  - None: 並び替えなし
  - Increasing: 昇順
  - Decreasing: 降順

## 高度な設定

### しきい値の設定

- **Thresholds**: しきい値の設定
  - 警告レベル
  - クリティカルレベル
- **Threshold mode**: しきい値のモード
  - Absolute: 絶対値
  - Percentage: パーセンテージ

### 変数の使用

```promql
# 変数を使用したクエリの例
node_memory_MemTotal_bytes{instance="$instance"}
```

### パネルのリンク

- **Panel links**: 他のダッシュボードやパネルへのリンク
- **URL**: 外部リンクの設定

## よく使う設定例

### CPU使用率の表示

```promql
# クエリ
100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# 推奨設定
- Unit: percent
- Min: 0
- Max: 100
- Thresholds: 
  - Warning: 70
  - Critical: 90
```

### メモリ使用率の表示

```promql
# クエリ
(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100

# 推奨設定
- Unit: percent
- Min: 0
- Max: 100
- Fill opacity: 0.2
- Gradient mode: Opacity
```

## 注意事項

- データの更新間隔は、データソースの設定に依存します
- パネルの設定は、JSONモデルとしてエクスポート/インポートできます
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/panels-visualizations/visualizations/time-series/)を参照してください 
