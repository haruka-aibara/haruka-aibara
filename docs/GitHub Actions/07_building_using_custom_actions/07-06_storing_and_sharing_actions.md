# アクションのリポジトリ保存と共有

GitHub Actionsは、ワークフローと同じリポジトリに保存するだけでなく、別のリポジトリに保存して共有することができます。これにより、アクションの再利用性が高まり、複数のプロジェクトで同じアクションを簡単に利用できるようになります。

## 主要概念

アクションを別リポジトリで管理することで、アクションのバージョン管理が容易になり、複数のプロジェクト間で一貫したアクションの利用が可能になります。また、GitHub Actions Marketplaceへの公開も可能になります。

## 実装手順

### 1. アクション用のプロジェクト作成

アクションの定義ファイルとコードは、プロジェクトのルートディレクトリに直接配置します。

### 2. アクションの共有

アクションをGitHubリポジトリに保存し、バージョンタグを付けることで、他のプロジェクトから利用できるようになります。

### 3. 他のワークフローでの利用

```yaml
# 他のプロジェクトのワークフローファイル
name: Using Shared Action
on: [push]

jobs:
  example:
    runs-on: ubuntu-latest
    steps:
      - uses: username/my-custom-action@v1
        with:
          input1: 'value1'
          input2: 'value2'
```

## セキュリティ考慮事項

- アクションを公開する前に、機密情報が含まれていないことを確認する
- アクションの入力パラメータは適切にバリデーションを行う
- 依存関係のバージョンは固定し、セキュリティアップデートを定期的に確認する
- 必要最小限の権限でアクションを実行するように設定する

## 参考資料

- [GitHub Actions のドキュメント](https://docs.github.com/ja/actions/creating-actions/publishing-actions-in-github-marketplace)
- [GitHub Marketplace](https://github.com/marketplace?type=actions) 
