# GitHub Actionsの開発でLinterを使う理由と設定方法

## なんでLinterが必要なの？

GitHub ActionsのワークフローファイルはYAMLで書きます。YAMLは読みやすい反面、以下のようなミスが起きやすいです：

- インデントのズレ
- キーの重複
- 値の型の間違い
- 必須項目の欠落
- アクションのバージョン指定ミス

こういったミスを事前に防ぐためにLinterは必須です。

## おすすめのLinter

### 1. actionlint

[actionlint](https://github.com/rhysd/actionlint)はGitHub Actions専用のLinterです。主な特徴：

- 高速な実行
- 詳細なエラーチェック
- アクションのバージョン検証
- シェルスクリプトの構文チェック
- 式の構文チェック

#### インストール方法

```bash
# macOS
brew install actionlint

# Windows
scoop install actionlint

# Linux
curl -L -o actionlint https://github.com/rhysd/actionlint/releases/latest/download/actionlint_linux_amd64
chmod +x actionlint
sudo mv actionlint /usr/local/bin/
```

#### 使い方

```bash
# 単一ファイルのチェック
actionlint .github/workflows/example.yml

# ディレクトリ内の全ファイルをチェック
actionlint .github/workflows/
```

### 2. yamllint

[yamllint](https://github.com/adrienverge/yamllint)はYAML全般のLinterです。基本的な構文チェック用に使えます。

#### インストール

```bash
pip install yamllint
```

#### 設定例（.yamllint）

```yaml
extends: default

rules:
  line-length: disable  # 長い行を許容
  truthy:
    allowed-values: ['true', 'false', 'yes', 'no']  # 真偽値の書き方を制限
```

## VSCodeでの設定

### 1. actionlintの設定

1. VSCodeに「GitHub Actions」拡張機能をインストール
2. settings.jsonに以下を追加：

```json
{
  "githubActions.lint.enable": true,
  "githubActions.lint.run": "onType"  // タイプ時にチェック
}
```

### 2. yamllintの設定

1. VSCodeに「YAML」拡張機能をインストール
2. settings.jsonに以下を追加：

```json
{
  "yaml.validate": true,
  "yaml.format.enable": true,
  "yaml.hover": true,
  "yaml.completion": true
}
```

## CIでの自動チェック

ワークフローファイルの品質を保証するために、以下のようなワークフローを設定しておくと良いです：

```yaml
name: Lint GitHub Actions

on:
  push:
    paths:
      - '.github/workflows/**'
  pull_request:
    paths:
      - '.github/workflows/**'

jobs:
  actionlint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: rhysd/action-actionlint@v1
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

## まとめ

Linterを使うメリット：

1. ミスの早期発見
2. ワークフローの品質向上
3. チーム開発の効率化
4. デプロイ時のトラブル防止

`actionlint`は特に便利で、VSCodeの設定とCIでの自動チェックを組み合わせることで、より効率的な開発が可能になります。 
