# Grafana Gaugeパネルガイド

GrafanaのGaugeパネルは、単一の値を視覚的に表示するためのパネルです。CPU使用率やメモリ使用率など、特定の値を監視するのに適しています。このガイドでは、Gaugeパネルの設定と使用方法について説明します。

## Gaugeパネルの基本

### パネルの作成

1. **新規パネルの追加**
   - ダッシュボードの編集画面を開く
   - 「Add panel」をクリック
   - 「Gauge」を選択

2. **データソースの設定**
   ```promql
   # 例：CPU使用率
   100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   
   # 例：メモリ使用率
   (node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100
   ```

### 表示設定

1. **基本設定**
   - タイトル
   - 説明
   - 単位（%、GB、MBなど）
   - 小数点以下の桁数

2. **ゲージの外観**
   - 最小値・最大値
   - しきい値の設定
   - 色の設定
   - 表示モード（円形、半円形、線形）

## 詳細設定

### しきい値の設定

1. **警告レベル**
   ```yaml
   # しきい値の例
   Thresholds:
     - value: 70
       color: yellow
       state: warning
     - value: 90
       color: red
       state: critical
   ```

2. **色のカスタマイズ**
   - 正常時の色
   - 警告時の色
   - 危険時の色

### 表示オプション

1. **値の表示**
   - 現在値
   - 最小値
   - 最大値
   - 平均値

2. **フォーマット**
   - 数値のフォーマット
   - 単位の表示
   - 小数点以下の桁数

## 実践的な設定例

### CPU使用率の表示

```yaml
# パネル設定
Title: CPU Usage
Query: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
Unit: percent
Min: 0
Max: 100
Thresholds:
  - 70 (warning)
  - 90 (critical)
Display:
  - Current value
  - Min/Max values
  - Threshold markers
```

### メモリ使用率の表示

```yaml
# パネル設定
Title: Memory Usage
Query: (node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100
Unit: percent
Min: 0
Max: 100
Thresholds:
  - 80 (warning)
  - 95 (critical)
Display:
  - Current value
  - Min/Max values
  - Threshold markers
```

## 高度な設定

### 変数の使用

1. **ダッシュボード変数**
   - インスタンスの選択
   - 時間範囲の設定
   - しきい値の動的設定

2. **条件付き表示**
   - 値に基づく表示の変更
   - しきい値に基づく色の変更
   - アラート状態の表示

### リンクの設定

1. **パネルリンク**
   - 詳細画面へのリンク
   - 関連ダッシュボードへのリンク
   - 外部システムへのリンク

2. **ツールチップ**
   - 詳細情報の表示
   - 補足説明の追加
   - 関連データの表示

## 注意事項

- しきい値は適切に設定してください
- 表示する値の範囲を考慮してください
- 更新間隔を適切に設定してください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/panels/visualizations/gauge/)を参照してください 
