# GitHub Actions - Running Workflow

## 概要
GitHub Actionsのワークフローの実行状態を理解し、モニタリングすることは、継続的インテグレーション/継続的デリバリー（CI/CD）パイプラインの効率的な管理に不可欠です。

## 理論的背景
ワークフローの実行（running workflow）とは、GitHub Actionsにおいて定義されたYAMLファイルに基づいて実際に処理が行われている状態を指します。

## Running Workflowの基本

### 実行状態の種類
GitHub Actionsのワークフローの実行状態には以下の種類があります：

- **queued**：実行待ちの状態
- **in_progress**：現在実行中の状態
- **completed**：実行が完了した状態（成功/失敗/キャンセル）

### 実行状態の確認方法

1. GitHub上での確認：
   - リポジトリのトップページから「Actions」タブをクリック
   - 実行中のワークフローは「In progress」セクションに表示
   - 各ワークフローの横に表示される色付きのアイコンで状態を確認できる
     - 黄色：実行中
     - 緑：成功
     - 赤：失敗

2. GitHub CLIでの確認：
   ```bash
   # 最新の実行状態を確認
   gh run list -L 10
   
   # 特定のワークフローの実行状態を確認
   gh workflow view <ワークフロー名や ID>
   ```

### 実行中のワークフローのログ確認

実行中のワークフローのログをリアルタイムで確認することができます：

1. GitHub UI上での確認：
   - Actionsタブから実行中のワークフロー実行をクリック
   - 各ジョブを展開して、実行中のステップのログを確認

2. GitHub CLIでのログ確認：
   ```bash
   # ワークフロー実行IDを指定してログを表示
   gh run view <実行ID> --log
   ```

### 実行中のワークフローの制御

1. キャンセル：
   - GitHub UI：実行中のワークフローページ右上の「Cancel workflow」ボタン
   - GitHub CLI：`gh run cancel <実行ID>`

2. 再実行：
   - GitHub UI：失敗したワークフローページ右上の「Re-run jobs」ボタン
   - GitHub CLI：`gh run rerun <実行ID>`

### ワークフロー実行のトラブルシューティング

実行中に問題が発生した場合の対処法：

1. **ログの詳細確認**：各ステップの詳細なログを確認し、エラーメッセージを特定

2. **実行環境の確認**：
   - ランナーのOSやバージョン
   - 使用しているアクションのバージョン
   - 必要な環境変数が正しく設定されているか

3. **タイムアウト問題**：
   - 長時間実行されるステップには `timeout-minutes` を設定
   - GitHub Actionsのデフォルトタイムアウト（6時間）を考慮

## 実行状態の監視と通知

### ステータスバッジの活用
README.mdにワークフロー実行状態のバッジを追加できます：

```markdown
![ワークフロー名](https://github.com/<ユーザー名>/<リポジトリ名>/actions/workflows/<ワークフローファイル名>/badge.svg)
```

### 通知の設定
ワークフロー実行結果に基づいて通知を設定できます：

1. メール通知：GitHub設定で「Actions」に関する通知を有効化
2. Slack通知：Slack連携アクションを使用
   ```yaml
   - name: Slack通知
     uses: 8398a7/action-slack@v3
     with:
       status: ${{ job.status }}
       fields: repo,message,commit,author,action,eventName,workflow
     env:
       SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
     if: always()  # 成功・失敗にかかわらず通知
   ```

## まとめ
GitHub Actionsのワークフロー実行状態を理解し、適切に監視・管理することで、CI/CDパイプラインの信頼性と効率を向上させることができます。問題が発生した場合も迅速に対応できるよう、ログの確認方法やトラブルシューティングの基本を把握しておきましょう。
