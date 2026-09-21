# Job Outputs

Job Outputsは、GitHub Actionsのワークフロー内でジョブ間でデータを共有するための重要な機能です。

Job Outputsは、あるジョブで生成された値を他のジョブで利用できるようにする仕組みで、ワークフローの柔軟性と効率性を高めます。

## 主な特徴

- **値の共有**: 文字列、数値、JSONなどのデータを共有可能
- **スコープ**: 同じワークフロー内のジョブ間でのみ共有可能
- **依存関係**: 出力を使用するジョブは、出力を生成するジョブに依存する必要がある
- **永続性**: ワークフロー実行中のみ有効

## 基本的な使用方法

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    outputs:
      first_output: ${{ steps.step1.outputs.value }}
    steps:
      - id: step1
        run: echo "value=hello" >> $GITHUB_OUTPUT

  job2:
    needs: job1
    runs-on: ubuntu-latest
    steps:
      - name: Use output
        run: echo ${{ needs.job1.outputs.first_output }}
```

## 複数の出力を設定する場合

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    outputs:
      output1: ${{ steps.step1.outputs.value1 }}
      output2: ${{ steps.step2.outputs.value2 }}
    steps:
      - id: step1
        run: echo "value1=hello" >> $GITHUB_OUTPUT
      - id: step2
        run: echo "value2=world" >> $GITHUB_OUTPUT
```

## 公式ドキュメント

- [GitHub Actions Job Outputs 公式ドキュメント](https://docs.github.com/ja/actions/using-workflows/workflow-commands-for-github-actions#setting-an-output-parameter)
