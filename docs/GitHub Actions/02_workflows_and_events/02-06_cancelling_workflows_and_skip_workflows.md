# ワークフローのキャンセルとスキップ

GitHub Actionsのワークフローを効率的に管理するための重要な機能である、ワークフローのキャンセルとスキップについて説明します。

## 概要

ワークフローのキャンセル（Cancelling Workflows）とスキップ（Skip Workflows）は、不要なワークフローの実行を防ぎ、CI/CDパイプラインの効率化を実現する重要な機能です。

## デフォルトの失敗動作

GitHub Actionsでは、以下のような階層的な失敗の伝播がデフォルトで設定されています：

- 1つのstepが失敗すると、そのstepを含むjob全体が失敗します
- 1つのjobが失敗すると、そのjobを含むworkflow全体が失敗します

この動作は、`continue-on-error` や `if` 条件を使用して制御することができます：

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Step that might fail
        continue-on-error: true  # このstepが失敗してもjobは続行
        run: echo "This might fail"
      
      - name: Another step
        if: success()  # 前のstepが成功した場合のみ実行
        run: echo "This runs only if previous step succeeded"
```

## 主要な機能

### ワークフローのキャンセル

- `concurrency` グループを使用して、同じブランチやプルリクエストで新しいワークフローが開始された場合に、実行中のワークフローを自動的にキャンセルできます
- 手動でワークフローをキャンセルすることも可能です
- キャンセルされたワークフローは、完了したジョブのステータスを保持します

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### ワークフローのスキップ

- コミットメッセージに `[skip ci]` や `[ci skip]` を含めることで、ワークフローの実行をスキップできます
- これらのキーワードは特別な意味を持ち、GitHub Actionsが自動的に認識します
- 特定の条件でワークフローをスキップする場合は、`if` 条件を使用します

```yaml
# [skip ci] や [ci skip] は自動的に認識されるため、特別な設定は不要です
# 例: git commit -m "Update docs [skip ci]"

# 特定の条件でスキップする場合は if 条件を使用
jobs:
  build:
    if: github.ref == 'refs/heads/main'  # mainブランチの場合のみ実行
    runs-on: ubuntu-latest
    steps:
      - name: Build
        run: echo "Building..."
```

## 重要なポイント

- キャンセル機能は、リソースの効率的な使用に役立ちます
- スキップ機能は、開発者の生産性を向上させます
- 両機能とも、CI/CDパイプラインの最適化に重要な役割を果たします
- 失敗の伝播を適切に制御することで、より柔軟なワークフロー設計が可能になります
- `[skip ci]` や `[ci skip]` は特別なキーワードとして自動的に認識されます

## 公式ドキュメント

- [Concurrency](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#concurrency)
- [Skipping workflow runs](https://docs.github.com/en/actions/managing-workflow-runs/skipping-workflow-runs)
- [Continue on error](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error)
