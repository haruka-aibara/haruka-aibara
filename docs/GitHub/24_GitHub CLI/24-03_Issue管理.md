# GitHub CLIでのIssue管理

## はじめに
GitHub CLIを使用すると、コマンドラインからIssueの作成、管理、操作を効率的に行うことができます。ブラウザを使わずに、ターミナルからGitHubのIssueを管理できます。

## ざっくり理解しよう
1. **Issueの基本操作**
   - Issueの作成
   - Issueの一覧表示
   - Issueの更新

2. **主な機能**
   - Issueの検索
   - Issueのコメント
   - Issueのラベル管理

3. **メリット**
   - 効率的な操作
   - 自動化の実現
   - 一貫性のある管理

## 実際の使い方
### Issueの作成
```bash
# 新しいIssueの作成
gh issue create [オプション]

# 例：タイトルと本文を指定
gh issue create --title "バグ修正" --body "詳細な説明"

# 例：ラベルを指定
gh issue create --label "bug" --label "high-priority"
```

### Issueの一覧表示
```bash
# Issueの一覧表示
gh issue list

# 例：特定のラベルのIssueを表示
gh issue list --label "bug"

# 例：特定の状態のIssueを表示
gh issue list --state "open"
```

## 手を動かしてみよう
### Issueの管理
```bash
# Issueの詳細表示
gh issue view <番号>

# Issueの更新
gh issue edit <番号> --title "新しいタイトル"

# Issueのクローズ
gh issue close <番号>
```

### Issueのコメント
```bash
# コメントの追加
gh issue comment <番号> --body "コメント内容"

# コメントの一覧表示
gh issue view <番号> --comments
```

## 実践的なサンプル
### Issueの作成と設定
```bash
# テンプレートを使用したIssueの作成
gh issue create \
  --title "新機能の追加" \
  --body "$(cat .github/ISSUE_TEMPLATE/feature.md)" \
  --label "enhancement" \
  --assignee "@me"

# 複数のIssueの一括作成
for i in {1..3}; do
  gh issue create \
    --title "タスク $i" \
    --body "タスク $i の説明" \
    --label "task"
done
```

### Issueの検索と操作
```bash
# 特定の条件でIssueを検索
gh issue list --search "is:open label:bug"

# Issueの一括更新
gh issue list --label "needs-review" | while read -r line; do
  number=$(echo "$line" | awk '{print $1}')
  gh issue edit "$number" --add-label "in-progress"
done
```

## 困ったときは
### よくあるトラブル
1. **Issueの作成に失敗**
   - 権限の確認
   - リポジトリの確認
   - ネットワーク接続の確認

2. **コメントの追加に失敗**
   - 認証の確認
   - Issue番号の確認
   - コメント内容の確認

3. **ラベルの設定に失敗**
   - ラベル名の確認
   - 権限の確認
   - リポジトリの設定確認

## もっと知りたい人へ
### 次のステップ
- 高度なIssue管理
- 自動化スクリプトの作成
- チーム開発での活用

### おすすめの学習リソース
- [GitHub CLI公式ドキュメント](https://cli.github.com/manual/gh_issue)
- [GitHub CLI Examples](https://github.com/cli/cli#examples)
- [GitHub Issues API](https://docs.github.com/ja/rest/issues)
