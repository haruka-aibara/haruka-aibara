# GitHub Actions の Fork における特別な動作

> 詳細は[公式ドキュメント: Approving workflow runs from public forks](https://docs.github.com/en/actions/managing-workflow-runs-and-deployments/managing-workflow-runs/approving-workflow-runs-from-public-forks)を参照してください。

GitHub Actions では、fork されたリポジトリからのワークフロー実行には特別な制限が設けられています。

## Fork からのワークフロー実行における承認（Approval）要件

fork されたリポジトリからワークフローを実行する場合、セキュリティ上の理由から、リポジトリの管理者による明示的な承認（Approval）が必要となります。これは、悪意のあるコードの実行を防ぐための重要なセキュリティ対策です。

### 承認が必要なケース
- フォークされたリポジトリからの Pull Request でワークフローを実行する場合
- フォークされたリポジトリのブランチからワークフローを実行する場合

### 重要な注意点
- `pull_request` イベントのフィルター条件（ブランチ名、ラベル、レビュー状態など）がすべて合致していても、fork からの場合は必ず承認が必要です
- これは、ワークフローの設定や条件に関係なく、fork からの実行には常に承認が必要ということを意味します

### 承認の設定方法
1. リポジトリの設定（Settings）に移動
2. Actions > General を選択
3. "Fork pull request workflows from outside collaborators" セクションで承認設定を構成

この設定により、フォークからのワークフロー実行を安全に管理することができます。
