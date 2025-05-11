# Conditional Jobs and Steps in GitHub Actions

GitHub Actions のワークフローにおいて、特定の条件に基づいてジョブやステップの実行を制御することは、効率的なCI/CDパイプラインを構築する上で重要な機能です。

条件分岐（Conditional Execution）を使用することで、特定のジョブやステップの実行結果に応じて、必要なジョブやステップのみを実行することができます。

## 特に重視するポイント

- 条件式は `if` キーワードを使用して記述します
- 条件式には、GitHub Actions のコンテキストや式（Expressions）を使用できます
- 条件分岐は、ジョブレベルとステップレベルの両方で設定可能です
- 条件式の評価結果が `true` の場合のみ、該当のジョブやステップが実行されます
- ステップに `id` を付けることで、そのステップの結果を後続のステップで参照できます
- デフォルトでは、いずれかのステップが失敗すると、後続のステップは実行されません
- 失敗後も後続のステップを実行したい場合は、`continue-on-error: true` または `if: failure()` を使用する必要があります

## 基本的な使用方法

### ステップの結果に基づく条件分岐

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run unit tests
        id: unit-tests
        run: |
          echo "Running unit tests"
          exit 1  # テストが失敗する例
      
      # デフォルトでは、unit-testsが失敗するとこのステップは実行されません
      - name: Run integration tests
        if: steps.unit-tests.outcome == 'failure'
        run: echo "Running integration tests after unit test failure"
      
      # 失敗後も実行するには、continue-on-error: true を追加
      - name: Run unit tests with continue
        id: unit-tests-continue
        continue-on-error: true
        run: |
          echo "Running unit tests"
          exit 1
      
      # または、failure() を使用して明示的に失敗を条件とする
      - name: Run integration tests after failure
        if: failure() && steps.unit-tests-continue.outcome == 'failure'
        run: echo "Running integration tests after unit test failure"
      
      - name: Send notification
        if: steps.unit-tests-continue.outcome == 'failure'
        run: echo "Sending failure notification"
```

### ジョブの結果に基づく条件分岐

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build
        run: echo "Building application"
  
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Run tests
        run: echo "Running tests"
  
  deploy:
    needs: [build, test]
    if: success()  # build と test の両方が成功した場合のみ実行
    runs-on: ubuntu-latest
    steps:
      - name: Deploy
        run: echo "Deploying application"
  
  notify:
    needs: [build, test]
    if: failure()  # build または test のいずれかが失敗した場合に実行
    runs-on: ubuntu-latest
    steps:
      - name: Send failure notification
        run: echo "Sending failure notification"
```

## よく使用される条件式の例

- `success()`: 前のステップが成功した場合
- `failure()`: 前のステップが失敗した場合
- `cancelled()`: ワークフローがキャンセルされた場合
- `always()`: 前のステップの結果に関わらず実行
- `steps.<step_id>.outcome`: 特定のステップの実行結果（'success', 'failure', 'cancelled', 'skipped'）

## 公式ドキュメント

- [GitHub Actions の式構文](https://docs.github.com/ja/actions/learn-github-actions/expressions)
- [GitHub Actions のコンテキスト](https://docs.github.com/ja/actions/learn-github-actions/contexts)
- [continue-on-error の設定](https://docs.github.com/ja/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepscontinue-on-error)
