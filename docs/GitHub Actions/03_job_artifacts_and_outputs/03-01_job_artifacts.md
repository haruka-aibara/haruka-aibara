# Job Artifacts

Job Artifactsは、GitHub Actionsのワークフロー実行中に生成されたファイルを保存・共有するための重要な機能です。

Job Artifactsは、ビルド成果物、テストレポート、ログファイルなどのワークフロー実行の結果を保存し、後でダウンロードや他のジョブで利用できるようにする仕組みです。

## 主な特徴

- **保存期間**: Artifactsはデフォルトで90日間保存されます
- **サイズ制限**: 1つのArtifactの最大サイズは10GBまで
- **圧縮**: 自動的に圧縮されて保存されます
- **アクセス制御**: リポジトリの権限設定に基づいてアクセス制御が可能

## 基本的な使用方法

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Create artifact
        run: echo "Hello World" > hello.txt
      
      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: my-artifact
          path: hello.txt
```

## 他のジョブでの利用

```yaml
jobs:
  download:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v3
        with:
          name: my-artifact
```

## 公式ドキュメント

- [GitHub Actions Artifacts 公式ドキュメント](https://docs.github.com/ja/actions/using-workflows/storing-workflow-data-as-artifacts)
