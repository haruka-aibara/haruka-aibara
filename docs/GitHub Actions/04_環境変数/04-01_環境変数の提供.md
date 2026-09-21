# GitHub Actionsにおける環境変数の提供方法

GitHub Actionsでは、ワークフローやジョブの実行時に必要な環境変数を様々な方法で提供することができます。

## 環境変数の提供方法

GitHub Actionsでは、環境変数を以下の方法で提供できます：
- ワークフローファイル内での直接定義
- GitHub Secretsの利用
- 環境変数ファイル（.env）の利用
- 環境変数の継承と上書き

## 重要なポイント

- 環境変数は `${{ env.VARIABLE_NAME }}` の形式で参照します
- 機密情報は必ずGitHub Secretsを使用して管理します
- 環境変数は大文字小文字を区別します
- 環境変数の優先順位：ジョブレベル > ワークフローレベル > リポジトリレベル

## リポジトリのシークレットの設定方法

1. GitHubリポジトリの「Settings」タブに移動
2. 左サイドバーの「Secrets and variables」→「Actions」を選択
3. 「New repository secret」ボタンをクリック
4. シークレットの名前と値を入力
5. 「Add secret」ボタンをクリック

シークレットの使用例：
```yaml
jobs:
  example-job:
    runs-on: ubuntu-latest
    steps:
      - name: Use repository secret
        run: |
          echo "Using secret: ${{ secrets.MY_SECRET }}"
```

## GitHub Environmentsの設定と使用方法

GitHub Environmentsは、デプロイメントの環境（開発、ステージング、本番など）ごとに異なる設定やシークレットを管理するための機能です。

### Environmentsの設定方法

1. GitHubリポジトリの「Settings」タブに移動
2. 左サイドバーの「Environments」を選択
3. 「New environment」ボタンをクリック
4. 環境名（例：`production`、`staging`）を入力
5. 必要に応じて保護ルールや環境変数を設定

### Environmentsの使用例

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # 環境を指定
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to ${{ env.ENVIRONMENT_NAME }}"
          echo "Using environment secret: ${{ secrets.ENV_SPECIFIC_SECRET }}"
```

### Environmentsの主な機能

1. **環境固有のシークレット**
   - 各環境ごとに異なるシークレットを設定可能
   - 例：本番環境用のデータベース接続情報

2. **保護ルール**
   - 特定のブランチからのみデプロイを許可
   - レビュー承認の必須化
   - タイムアウトの設定

3. **環境変数**
   - 環境ごとに異なる環境変数を設定可能
   - 例：`NODE_ENV`、`API_URL`など

### 環境変数の優先順位

1. ジョブレベル
2. ワークフローレベル
3. 環境レベル
4. リポジトリレベル

## デフォルトの環境変数

GitHub Actionsには、自動的に設定されるデフォルトの環境変数があります：

### リポジトリ情報
- `GITHUB_REPOSITORY`: リポジトリの所有者と名前（例：`octocat/Hello-World`）
- `GITHUB_REF`: ブランチまたはタグのref（例：`refs/heads/feature-branch`）
- `GITHUB_SHA`: コミットのSHA

### ワークフロー情報
- `GITHUB_WORKFLOW`: ワークフローの名前
- `GITHUB_RUN_ID`: ワークフロー実行の一意の番号
- `GITHUB_RUN_NUMBER`: リポジトリ内のワークフロー実行の一意の番号

### ジョブ情報
- `GITHUB_JOB`: 現在のジョブのID
- `RUNNER_OS`: ランナーのオペレーティングシステム

使用例：
```yaml
jobs:
  example-job:
    runs-on: ubuntu-latest
    steps:
      - name: Use default variables
        run: |
          echo "Repository: ${{ env.GITHUB_REPOSITORY }}"
          echo "Branch: ${{ env.GITHUB_REF }}"
          echo "Commit SHA: ${{ env.GITHUB_SHA }}"
```

## 基本的な使用方法

```yaml
name: Environment Variables Example

on: [push]

jobs:
  example-job:
    runs-on: ubuntu-latest
    env:
      NODE_ENV: production
      DATABASE_URL: ${{ secrets.DATABASE_URL }}
    steps:
      - name: Use environment variables
        run: |
          echo "Environment: ${{ env.NODE_ENV }}"
          echo "Database URL is set: ${{ env.DATABASE_URL != '' }}"
```

## 環境変数の設定場所

1. ワークフローレベル
```yaml
env:
  VARIABLE_NAME: value
```

2. ジョブレベル
```yaml
jobs:
  job-name:
    env:
      VARIABLE_NAME: value
```

3. ステップレベル
```yaml
steps:
  - name: Step name
    env:
      VARIABLE_NAME: value
```

## 参考リンク

- [GitHub Actions の環境変数](https://docs.github.com/ja/actions/learn-github-actions/variables)
- [GitHub Actions のシークレット](https://docs.github.com/ja/actions/security-guides/encrypted-secrets)
- [GitHub Actions のデフォルト環境変数](https://docs.github.com/ja/actions/learn-github-actions/variables#default-environment-variables)
