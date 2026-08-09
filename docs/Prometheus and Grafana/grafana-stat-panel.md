# Grafana Statパネルガイド

GrafanaのStatパネルは、単一の重要な値を目立って表示するためのパネルです。現在の値、変化率、傾向などを視覚的に表示するのに適しています。このガイドでは、Statパネルの設定と使用方法について説明します。

## Statパネルの基本

### パネルの作成

1. **新規パネルの追加**
   - ダッシュボードの編集画面を開く
   - 「Add panel」をクリック
   - 「Stat」を選択

2. **データソースの設定**
   ```promql
   # 例：現在のCPU使用率
   sum(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100
   
   # 例：メモリ使用量
   node_memory_MemTotal_bytes - node_memory_MemFree_bytes
   ```

### 表示設定

1. **基本設定**
   - タイトル
   - 説明
   - 値の表示形式
   - 単位の設定

2. **表示モード**
   - 単一値
   - 複数値
   - ゲージ表示
   - カラー表示

## 詳細設定

### 値の表示設定

1. **値のフォーマット**
   ```yaml
   # 表示設定の例
   Display:
     mode: single
     valueSize: large
     colorMode: value
     graphMode: area
     justifyMode: auto
   ```

2. **単位と小数点**
   - 単位の選択
   - 小数点以下の桁数
   - 数値のフォーマット
   - プレフィックス/サフィックス

### 色としきい値

1. **しきい値の設定**
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

2. **色の設定**
   - 値に基づく色
   - 傾向に基づく色
   - カスタムカラー
   - グラデーション

## 実践的な設定例

### システムメトリクスの表示

```yaml
# パネル設定
Title: System Health
Query: 
  - CPU Usage: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
  - Memory Usage: (node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100
Display:
  mode: multiple
  valueSize: medium
  colorMode: value
  graphMode: area
Thresholds:
  - 70 (warning)
  - 90 (critical)
```

### アプリケーション統計の表示

```yaml
# パネル設定
Title: Application Stats
Query: 
  - Request Rate: sum(rate(http_requests_total[5m]))
  - Error Rate: sum(rate(http_requests_total{status=~"5.."}[5m]))
Display:
  mode: multiple
  valueSize: large
  colorMode: background
  graphMode: none
```

## 高度な設定

### 値の計算

1. **計算フィールド**
   - 合計値の計算
   - 平均値の計算
   - 変化率の計算
   - カスタム計算

2. **データの変換**
   - 単位の変換
   - 時間のフォーマット
   - 数値の丸め
   - 条件付き表示

### インタラクティブ機能

1. **リンクの設定**
   - 詳細画面へのリンク
   - 関連ダッシュボードへのリンク
   - 外部システムへのリンク

2. **ツールチップ**
   - 詳細情報の表示
   - 補足説明の追加
   - 関連データの表示

## 注意事項

- 表示する値の重要性を考慮してください
- 適切なしきい値を設定してください
- 更新間隔を適切に設定してください
- より詳細な設定や使用方法については、[公式ドキュメント](https://grafana.com/docs/grafana/latest/panels/visualizations/stat/)を参照してください 
