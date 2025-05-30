# commit-msgフック

## はじめに
「コミットメッセージの形式を統一したい」「コミットメッセージに特定の情報を含めたい」という経験はありませんか？Gitでは、`commit-msg`フックを使用して、コミットメッセージの形式をチェックすることができます。この記事では、`commit-msg`フックの使い方と、その活用シーンについて解説します。

## ざっくり理解しよう
1. **コミットメッセージのチェック**: コミットメッセージの形式をチェックできる
2. **コミットメッセージの修正**: コミットメッセージを自動的に修正できる
3. **コミットメッセージの検証**: コミットメッセージが要件を満たしているかを検証できる

## 実際の使い方
### 基本的な使い方
1. フックスクリプトを作成する
```bash
# .git/hooks/commit-msgファイルを作成
touch .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

2. フックスクリプトを編集する
```bash
#!/bin/sh
# コミットメッセージの形式をチェック
if ! grep -qE '^(feat|fix|docs|style|refactor|test|chore):' "$1"; then
    echo "Error: コミットメッセージの形式が正しくありません。"
    echo "例: feat: 新機能の追加"
    exit 1
fi
```

### よくある使用シーン
1. **コミットメッセージの形式チェック**: コミットメッセージの形式をチェック
2. **コミットメッセージの自動修正**: コミットメッセージを自動的に修正
3. **コミットメッセージの検証**: コミットメッセージが要件を満たしているかを検証

## 手を動かしてみよう
1. フックスクリプトを作成する
```bash
# .git/hooks/commit-msgファイルを作成
touch .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
```

2. フックスクリプトを編集する
```bash
#!/bin/sh
# コミットメッセージの形式をチェック
if ! grep -qE '^(feat|fix|docs|style|refactor|test|chore):' "$1"; then
    echo "Error: コミットメッセージの形式が正しくありません。"
    echo "例: feat: 新機能の追加"
    exit 1
fi
```

## 実践的なサンプル
### コミットメッセージの形式チェック
```bash
#!/bin/sh
# コミットメッセージの形式をチェック
if ! grep -qE '^(feat|fix|docs|style|refactor|test|chore):' "$1"; then
    echo "Error: コミットメッセージの形式が正しくありません。"
    echo "例: feat: 新機能の追加"
    exit 1
fi
```

### コミットメッセージの自動修正
```bash
#!/bin/sh
# コミットメッセージを自動的に修正
sed -i 's/^/feat: /' "$1"
```

### コミットメッセージの検証
```bash
#!/bin/sh
# コミットメッセージが要件を満たしているかを検証
if ! grep -qE '^(feat|fix|docs|style|refactor|test|chore):' "$1"; then
    echo "Error: コミットメッセージの形式が正しくありません。"
    echo "例: feat: 新機能の追加"
    exit 1
fi

if ! grep -qE '^.{10,100}$' "$1"; then
    echo "Error: コミットメッセージの長さが正しくありません。"
    echo "10文字以上100文字以下で入力してください。"
    exit 1
fi
```

## 困ったときは
### よくあるトラブル
1. **フックが実行されない場合**
   - フックスクリプトの実行権限を確認
   - フックスクリプトのパスを確認

2. **フックが正しく動作しない場合**
   - フックスクリプトの内容を確認
   - エラーメッセージを確認

### デバッグの手順
1. フックスクリプトの実行権限を確認
2. フックスクリプトの内容を確認
3. エラーメッセージを確認
4. 必要に応じてフックスクリプトを修正

## もっと知りたい人へ
### 次のステップ
- pre-commitフックを学ぶ
- post-commitフックを学ぶ
- pre-pushフックを学ぶ

### おすすめの学習リソース
- [Git公式ドキュメント](https://git-scm.com/docs/githooks)
- [Pro Git Book](https://git-scm.com/book/ja/v2)
- [GitHub Docs](https://docs.github.com/ja)

### コミュニティ情報
- [GitHub Discussions](https://github.com/git/git/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/git)
- [GitHub Community](https://github.community/)
