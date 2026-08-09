# リベース（git rebase）

## はじめに
「コミット履歴を整理したい」「ブランチの分岐点を変更したい」という経験はありませんか？Gitでは、`git rebase`コマンドを使用して、コミット履歴を整理することができます。この記事では、リベースの使い方と、その活用シーンについて解説します。

## ざっくり理解しよう
1. **コミット履歴の整理**: コミット履歴を整理し、より分かりやすい履歴を作成できる
2. **ブランチの分岐点の変更**: ブランチの分岐点を変更し、最新の変更を取り込める
3. **コミットの統合**: 複数のコミットを1つにまとめることができる

## 実際の使い方
### 基本的な使い方
```bash
# 現在のブランチを指定したブランチの上にリベース
git rebase <base_branch>

# 対話的なリベース
git rebase -i <base_commit>
```

### よくある使用シーン
1. **コミット履歴の整理**: コミット履歴を整理し、より分かりやすい履歴を作成
2. **ブランチの分岐点の変更**: ブランチの分岐点を変更し、最新の変更を取り込む
3. **コミットの統合**: 複数のコミットを1つにまとめる

## 手を動かしてみよう
1. リベースを開始する
```bash
# 現在のブランチを指定したブランチの上にリベース
git rebase <base_branch>

# 対話的なリベース
git rebase -i <base_commit>
```
2. 必要に応じてコンフリクトを解決
3. リベースを完了
```bash
git rebase --continue
```

## 実践的なサンプル
```bash
# 現在のブランチをmainブランチの上にリベース
git rebase main

# 対話的なリベース
git rebase -i HEAD~3

# リベースを中止
git rebase --abort

# リベースを続行
git rebase --continue

# リベースをスキップ
git rebase --skip
```

## 困ったときは
### よくあるトラブル
1. **コンフリクトが発生した場合**
   - コンフリクトを解決
   - `git add`で変更をステージ
   - `git rebase --continue`でリベースを続行

2. **リベースを中止したい場合**
   - `git rebase --abort`でリベースを中止
   - 元の状態に戻る

### デバッグの手順
1. `git status`でリベースの状態を確認
2. コンフリクトを解決
3. 変更をステージ
4. リベースを続行

## もっと知りたい人へ
### 次のステップ
- コミットの修正を学ぶ
- フィルターブランチを学ぶ
- 強制プッシュを学ぶ

### おすすめの学習リソース
- [Git公式ドキュメント](https://git-scm.com/docs/git-rebase)
- [Pro Git Book](https://git-scm.com/book/ja/v2)
- [GitHub Docs](https://docs.github.com/ja)

### コミュニティ情報
- [GitHub Discussions](https://github.com/git/git/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/git)
- [GitHub Community](https://github.community/)
