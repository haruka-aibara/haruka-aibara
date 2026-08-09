# コミットの修正（git commit --amend）

## はじめに
「コミットメッセージを間違えた」「最後のコミットに変更を追加したい」という経験はありませんか？Gitでは、`git commit --amend`コマンドを使用して、最後のコミットを修正することができます。この記事では、コミットの修正方法と、その活用シーンについて解説します。

## ざっくり理解しよう
1. **コミットメッセージの修正**: 最後のコミットのメッセージを変更できる
2. **コミット内容の修正**: 最後のコミットに変更を追加できる
3. **コミットの取り消し**: 最後のコミットを取り消し、新しいコミットを作成できる

## 実際の使い方
### 基本的な使い方
```bash
# コミットメッセージを修正
git commit --amend -m "新しいコミットメッセージ"

# ステージされた変更を最後のコミットに追加
git add .
git commit --amend --no-edit
```

### よくある使用シーン
1. **コミットメッセージの修正**: タイプミスや誤字を修正
2. **コミット内容の修正**: 忘れた変更を追加
3. **コミットの取り消し**: 間違ったコミットを取り消し

## 手を動かしてみよう
1. コミットを修正する
```bash
# コミットメッセージを修正
git commit --amend -m "新しいコミットメッセージ"

# ステージされた変更を最後のコミットに追加
git add .
git commit --amend --no-edit
```
2. 変更を確認
```bash
git log
```

## 実践的なサンプル
```bash
# コミットメッセージを修正
git commit --amend -m "新しいコミットメッセージ"

# ステージされた変更を最後のコミットに追加
git add .
git commit --amend --no-edit

# コミットの作者情報を修正
git commit --amend --author="新しい作者名 <email@example.com>"

# コミットの日時を修正
git commit --amend --date="2023-01-01 12:00:00"
```

## 困ったときは
### よくあるトラブル
1. **コミットが既にプッシュされている場合**
   - `git push --force`を使用して強制的にプッシュ
   - チームメンバーに通知する

2. **コミットの修正が反映されない場合**
   - `git log`でコミット履歴を確認
   - コミットが正しく修正されているか確認

### デバッグの手順
1. `git log`でコミット履歴を確認
2. コミットを修正
3. 変更を確認
4. 必要に応じてプッシュ

## もっと知りたい人へ
### 次のステップ
- リベースを学ぶ
- フィルターブランチを学ぶ
- 強制プッシュを学ぶ

### おすすめの学習リソース
- [Git公式ドキュメント](https://git-scm.com/docs/git-commit)
- [Pro Git Book](https://git-scm.com/book/ja/v2)
- [GitHub Docs](https://docs.github.com/ja)

### コミュニティ情報
- [GitHub Discussions](https://github.com/git/git/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/git)
- [GitHub Community](https://github.community/)
