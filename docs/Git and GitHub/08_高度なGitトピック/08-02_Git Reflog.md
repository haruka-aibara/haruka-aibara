# Git Reflog

## はじめに

「誤ってブランチを削除してしまった」「間違えてリセットしてしまった」そんな経験はありませんか？Git Reflogは、そんな緊急事態からあなたの作業を救い出す強力なツールです。この記事では、Git Reflogの基本的な使い方から実践的な活用方法まで解説します。

## ざっくり理解しよう

Git Reflogの重要なポイントは以下の3つです：

1. **作業履歴の完全な記録**
   - すべてのHEADの変更履歴を保持
   - ブランチの切り替え、コミット、リセットなどの操作を記録
   - 過去の作業状態を復元可能

2. **安全網としての機能**
   - 誤操作からの復旧が可能
   - 削除したブランチの復元
   - リセットしたコミットの復活

3. **時限的な記録**
   - デフォルトで30日間の履歴を保持
   - 古い履歴は自動的に削除
   - 必要に応じて保持期間を調整可能

## 実際の使い方

### 基本的な使い方

1. リフログの表示
```bash
# すべてのリフログを表示
git reflog

# 特定のブランチのリフログを表示
git reflog show <branch-name>
```

2. 特定の操作の履歴を確認
```bash
# コミット操作の履歴
git reflog show HEAD

# ブランチ操作の履歴
git reflog show refs/heads/<branch-name>
```

### 復旧操作

1. 削除したブランチの復元
```bash
# リフログから該当のコミットハッシュを確認
git reflog

# ブランチを復元
git branch <branch-name> <commit-hash>
```

2. リセットしたコミットの復活
```bash
# リフログから該当のコミットハッシュを確認
git reflog

# コミットを復元
git reset --hard <commit-hash>
```

## 手を動かしてみよう

### 基本的な手順

1. リフログの確認
```bash
# 現在のリフログを確認
git reflog
```

2. 特定の操作の履歴を確認
```bash
# 直近の5件の履歴を表示
git reflog -n 5

# 特定の日付以降の履歴を表示
git reflog --since="2 days ago"
```

3. 復旧操作の実行
```bash
# 特定のコミットに戻る
git reset --hard HEAD@{1}

# 削除したブランチを復元
git branch <branch-name> HEAD@{2}
```

## 実践的なサンプル

### リフログの出力例

```bash
# リフログの出力例
$ git reflog
abc1234 HEAD@{0}: commit: 最新のコミット
def5678 HEAD@{1}: checkout: moving from main to feature
ghi9012 HEAD@{2}: commit: 前回のコミット
```

### 復旧スクリプトの例

```bash
#!/bin/bash
# restore-branch.sh

# 引数からブランチ名を取得
BRANCH_NAME=$1

# リフログから該当のブランチの最後のコミットを探す
COMMIT_HASH=$(git reflog | grep "checkout: moving from.*to $BRANCH_NAME" | head -n 1 | awk '{print $1}')

# ブランチを復元
if [ ! -z "$COMMIT_HASH" ]; then
    git branch $BRANCH_NAME $COMMIT_HASH
    echo "ブランチ $BRANCH_NAME を復元しました"
else
    echo "ブランチ $BRANCH_NAME の履歴が見つかりません"
fi
```

## 困ったときは

### よくあるトラブルと解決方法

1. **リフログが表示されない場合**
```bash
# リポジトリが正しく初期化されているか確認
git status

# リフログの保持期間を確認
git config --get gc.reflogExpire
```

2. **古い履歴が消えている場合**
```bash
# リフログの保持期間を延長
git config gc.reflogExpire 90
git config gc.reflogExpireUnreachable 90
```

3. **特定の操作の履歴が見つからない場合**
```bash
# より詳細なリフログを表示
git reflog --all

# 特定のパターンで検索
git reflog | grep "commit"
```

### 予防するためのコツ

- 重要な操作の前にリフログを確認
- 定期的なバックアップの作成
- リフログの保持期間の適切な設定

## もっと知りたい人へ

### 次のステップ

- リフログの自動バックアップ
- 高度な復旧シナリオ
- リフログの最適化

### おすすめの学習リソース

- [Git公式ドキュメント - Reflog](https://git-scm.com/docs/git-reflog)
- [Pro Git Book - リフログ](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%83%84%E3%83%BC%E3%83%AB-%E3%83%AA%E3%83%95%E3%83%AD%E3%82%B0)

### コミュニティ情報

- [GitHub Discussions](https://github.com/git/git/discussions)
- [Stack Overflow - git-reflog](https://stackoverflow.com/questions/tagged/git-reflog)
