# GitHub Actions のワークフロー出力（outputs）

## 概要

再利用可能なワークフローで`outputs`を使用することで、呼び出し元に値を返すことができます。

## 基本構造

```yaml
# 再利用可能なワークフロー
on:
  workflow_call:
    outputs:
      output_name:
        description: '出力値の説明'
        value: ${{ jobs.job_id.outputs.output_name }}

jobs:
  job_id:
    runs-on: ubuntu-latest
    outputs:
      output_name: ${{ steps.step_id.outputs.output_name }}
    steps:
      - id: step_id
        run: echo "output_name=値" >> $GITHUB_OUTPUT

# 呼び出し元
jobs:
  call-workflow:
    uses: ./.github/workflows/reusable.yml

  use-output:
    needs: call-workflow
    runs-on: ubuntu-latest
    steps:
      - name: Use output
        run: echo "${{ needs.call-workflow.outputs.output_name }}"
```

## 使用例

### 1. ビルド結果の出力

```yaml
# 再利用可能なワークフロー
on:
  workflow_call:
    outputs:
      build_version:
        value: ${{ jobs.build.outputs.version }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.get_version.outputs.version }}
    steps:
      - id: get_version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT

# 呼び出し元
jobs:
  build:
    uses: ./.github/workflows/build.yml

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy version
        run: echo "Deploying version ${{ needs.build.outputs.build_version }}"
```

### 2. テスト結果の出力

```yaml
# 再利用可能なワークフロー
on:
  workflow_call:
    outputs:
      test_result:
        value: ${{ jobs.test.outputs.result }}

jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      result: ${{ steps.run_tests.outputs.result }}
    steps:
      - id: run_tests
        run: |
          if [ $? -eq 0 ]; then
            echo "result=success" >> $GITHUB_OUTPUT
          else
            echo "result=failure" >> $GITHUB_OUTPUT
          fi
```

## 注意点

1. 出力値は文字列として扱われる
2. 複雑なデータはJSON形式で出力する
3. 出力値は後続のジョブでのみ使用可能
4. 出力値の設定は`$GITHUB_OUTPUT`環境ファイルを使用 
