# GitHub Actions Events that trigger workflows

GitHub Actionsのワークフローを起動するイベントは、CI/CDパイプラインを効率的に自動化するための重要な要素です。イベントはワークフローをいつ実行するかを定義し、リポジトリの特定のアクティビティに応じて自動化されたプロセスを開始します。

## イベントの基本概念

ワークフローをトリガーするイベントは、`on:` キーワードを使用してワークフローファイル（YAML）内で定義され、複数のイベントを組み合わせることも可能です。

## reference

https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows

## 主要なワークフロートリガーイベント

### プッシュイベント

```yaml
on:
  push:
    branches: [ main, develop ]
    paths-ignore: [ 'docs/**', '**.md' ]
```

- コード変更がリポジトリにプッシュされたときにワークフローを実行
- `branches`で特定のブランチに限定可能
- `paths`や`paths-ignore`で特定のファイルに対するプッシュのみトリガー可能

### プルリクエストイベント

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
    branches: [ main ]
```

- PRが作成・更新されたときにワークフローを実行
- `types`で特定のPRアクションに限定可能
- `branches`でターゲットブランチを指定可能

### スケジュールイベント

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # 毎日午前0時に実行
```

- cron構文を使用して定期的にワークフローを実行
- タイムゾーンはUTC

### 手動トリガー（workflow_dispatch）

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: '環境を選択'
        required: true
        default: 'development'
        type: choice
        options:
          - development
          - staging
          - production
```

- 手動でワークフローを実行可能
- GitHubのUIやAPIから起動可能
- オプションの入力パラメータを定義可能

### リポジトリディスパッチ（repository_dispatch）

```yaml
on:
  repository_dispatch:
    types: [deploy, rollback]
```

- WebhookのPOSTリクエストを使用して外部からワークフローをトリガー
- カスタムイベントタイプを定義可能

### その他の主要イベント

```yaml
on:
  issues:
    types: [opened, edited, labeled]
  
  issue_comment:
    types: [created, edited]
  
  release:
    types: [published, created]
  
  workflow_run:
    workflows: ["テスト実行"]
    types: [completed]
    
  workflow_call:
    # 他のワークフローから呼び出し可能なワークフロー
```

## フィルタリングパターン

```yaml
on:
  push:
    branches:
      - 'main'
      - 'releases/**'     # releaseで始まるすべてのブランチ
      - '!releases/**-alpha' # alphaで終わるreleaseブランチを除外
    tags:
      - 'v*'              # vで始まるすべてのタグ
    paths:
      - '**.js'           # JavaScriptファイルのみ
```

- ワイルドカード（*）：0文字以上の任意の文字にマッチ
- 二重ワイルドカード（**）：任意のディレクトリにマッチ
- 否定パターン（!）：パターンを除外

## 環境変数とコンテキスト

```yaml
jobs:
  print-event-info:
    runs-on: ubuntu-latest
    steps:
      - name: イベント情報の表示
        run: |
          echo "イベント名: ${{ github.event_name }}"
          echo "ブランチ名: ${{ github.ref }}"
```

- `github.event_name`：トリガーされたイベントの名前
- `github.event`：イベントペイロードの完全な内容

## ベストプラクティス

1. **必要なイベントだけをトリガーに設定する**
   - 不要なワークフロー実行を避け、GitHub Actions分数を節約

2. **イベントフィルタリングを活用する**
   - 特定のブランチやファイルの変更時のみ実行

3. **ワークフロー間の依存関係を適切に管理する**
   - `workflow_run`や`workflow_call`を使用

4. **テスト用と本番用のイベントを区別する**
   - 例：フィーチャーブランチではテストのみ実行、mainブランチではデプロイまで実行

5. **手動トリガーのバックアップを用意する**
   - 自動トリガーが失敗した場合の手動実行オプション
