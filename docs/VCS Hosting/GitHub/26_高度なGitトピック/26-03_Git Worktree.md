# Git Worktree

## はじめに

「複数のブランチで同時に作業したい」「本番環境と開発環境のコードを同時に確認したい」そんな要望はありませんか？Git Worktreeは、1つのリポジトリで複数の作業ディレクトリを管理できる強力なツールです。この記事では、Git Worktreeの基本的な使い方から実践的な活用方法まで解説します。

## ざっくり理解しよう

Git Worktreeの重要なポイントは以下の3つです：

1. **複数作業ディレクトリの管理**
   - 1つのリポジトリで複数の作業ディレクトリを作成可能
   - 各作業ディレクトリは独立して動作
   - ブランチごとに別々の作業環境を構築可能

2. **効率的な開発フロー**
   - ブランチの切り替えが不要
   - 並行開発が容易
   - コンテキストスイッチのコストを削減

3. **柔軟な環境構築**
   - 本番環境と開発環境の同時確認
   - コードレビューと実装の並行作業
   - テスト環境の分離

## 実際の使い方

### 基本的な使い方

1. 作業ディレクトリの追加
```bash
# 新しい作業ディレクトリを作成
git worktree add ../feature-branch feature-branch

# 特定のコミットをチェックアウト
git worktree add ../hotfix hotfix-branch
```

2. 作業ディレクトリの一覧表示
```bash
# 現在の作業ディレクトリを表示
git worktree list

# 詳細情報を含めて表示
git worktree list --porcelain
```

3. 作業ディレクトリの削除
```bash
# 作業ディレクトリを削除
git worktree remove ../feature-branch

# 強制削除
git worktree remove -f ../feature-branch
```

## 手を動かしてみよう

### 基本的な手順

1. 作業ディレクトリの作成
```bash
# メインディレクトリに移動
cd /path/to/repository

# 新しい作業ディレクトリを作成
git worktree add ../feature-1 feature-1
```

2. 作業ディレクトリでの作業
```bash
# 新しい作業ディレクトリに移動
cd ../feature-1

# 通常のGit操作を実行
git status
git add .
git commit -m "作業内容"
```

3. 作業ディレクトリの管理
```bash
# 作業ディレクトリの一覧を確認
git worktree list

# 不要な作業ディレクトリを削除
git worktree remove ../feature-1
```

## 実践的なサンプル

### 開発環境の構築例

```bash
#!/bin/bash
# setup-worktrees.sh

# メインディレクトリ
REPO_DIR="/path/to/repository"
WORKTREE_BASE="../worktrees"

# 作業ディレクトリの作成
git worktree add "$WORKTREE_BASE/development" development
git worktree add "$WORKTREE_BASE/staging" staging
git worktree add "$WORKTREE_BASE/production" production

# 各環境の設定
for env in development staging production; do
    cd "$WORKTREE_BASE/$env"
    # 環境固有の設定を適用
    cp .env.$env .env
    npm install
done
```

### 並行開発の例

```bash
# 機能開発用の作業ディレクトリ
git worktree add ../feature-a feature-a
git worktree add ../feature-b feature-b

# バグ修正用の作業ディレクトリ
git worktree add ../hotfix hotfix

# コードレビュー用の作業ディレクトリ
git worktree add ../review pr-123
```

## 困ったときは

### よくあるトラブルと解決方法

1. **作業ディレクトリが削除できない場合**
```bash
# 作業ディレクトリが存在するか確認
git worktree list

# 強制削除を実行
git worktree remove -f ../worktree-name
```

2. **作業ディレクトリが壊れた場合**
```bash
# 作業ディレクトリを修復
git worktree repair

# 特定の作業ディレクトリを修復
git worktree repair ../worktree-name
```

3. **作業ディレクトリの競合が発生した場合**
```bash
# 作業ディレクトリの状態を確認
git worktree list --porcelain

# 競合を解決してから再試行
git worktree remove ../worktree-name
git worktree add ../worktree-name branch-name
```

### 予防するためのコツ

- 作業ディレクトリの命名規則を統一
- 定期的な作業ディレクトリの整理
- 作業ディレクトリの状態を定期的に確認

## もっと知りたい人へ

### 次のステップ

- 作業ディレクトリの自動管理
- CI/CDパイプラインとの連携
- 大規模プロジェクトでの活用方法

### おすすめの学習リソース

- [Git公式ドキュメント - Worktree](https://git-scm.com/docs/git-worktree)
- [Pro Git Book - Worktree](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%83%84%E3%83%BC%E3%83%AB-%E3%83%AF%E3%83%BC%E3%82%AF%E3%83%88%E3%83%AA%E3%83%BC)

### コミュニティ情報

- [GitHub Discussions](https://github.com/git/git/discussions)
- [Stack Overflow - git-worktree](https://stackoverflow.com/questions/tagged/git-worktree)
