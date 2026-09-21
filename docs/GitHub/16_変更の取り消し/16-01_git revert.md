# git revert

## はじめに

「コミットを取り消したいけど、履歴は残したい...」
「公開済みのコミットを安全に取り消すには...」
「複数のコミットを一度に取り消したい...」

Gitで変更を取り消す際に、このような悩みを抱えたことはありませんか？git revertコマンドは、既存のコミットの変更を取り消す新しいコミットを作成する安全な方法です。この記事では、git revertの使い方と実践的な活用方法について解説します。

## ざっくり理解しよう

git revertの重要なポイントは以下の3つです：

1. **安全な取り消し**
   - 履歴を残したまま変更を取り消す
   - 新しいコミットとして記録
   - 公開済みの変更にも使用可能

2. **柔軟な適用範囲**
   - 単一のコミットの取り消し
   - 複数コミットの一括取り消し
   - マージコミットの取り消し

3. **競合の管理**
   - 自動的な競合解決
   - 手動での競合解決
   - 取り消しの中断と再開

## 実際の使い方

### よくある使用シーン

1. **バグ修正の取り消し**
   - 問題のある修正の取り消し
   - 副作用のある変更の取り消し
   - 誤った修正の取り消し

2. **機能のロールバック**
   - 問題のある機能の無効化
   - 一時的な機能の削除
   - 実験的な機能の取り消し

3. **セキュリティ修正**
   - セキュリティ問題のある変更の取り消し
   - 機密情報の漏洩防止
   - 脆弱性の修正

## 手を動かしてみよう

### 基本的な使い方

1. 単一のコミットを取り消す
```bash
git revert <commit-hash>
```

2. 複数のコミットを取り消す
```bash
git revert <commit-hash-1> <commit-hash-2>
```

3. マージコミットを取り消す
```bash
git revert -m 1 <merge-commit-hash>
```

## 実践的なサンプル

### 単一のコミットの取り消し

```bash
# 特定のコミットを取り消す
git revert a1b2c3d

# 取り消しコミットのメッセージを編集
git revert -e a1b2c3d

# 取り消しをステージングのみで行う
git revert -n a1b2c3d
```

### 複数コミットの取り消し

```bash
# 連続した複数のコミットを取り消す
git revert HEAD~3..HEAD

# 特定の範囲のコミットを取り消す
git revert a1b2c3d..e4f5g6h

# 取り消しをステージングのみで行う
git revert -n HEAD~3..HEAD
```

### マージコミットの取り消し

```bash
# マージコミットを取り消す（mainブランチ側）
git revert -m 1 <merge-commit-hash>

# マージコミットを取り消す（featureブランチ側）
git revert -m 2 <merge-commit-hash>

# マージコミットの取り消しをステージングのみで行う
git revert -n -m 1 <merge-commit-hash>
```

## 困ったときは

### よくあるトラブルと解決方法

1. **競合の発生**
   - 問題：取り消し時に競合が発生
   - 解決：競合を解決後、`git revert --continue`

2. **取り消しの中断**
   - 問題：取り消しを途中で止めたい
   - 解決：`git revert --abort`で取り消しを中止

3. **誤った取り消し**
   - 問題：間違ったコミットを取り消した
   - 解決：取り消しの取り消し（`git revert`）を実行

## もっと知りたい人へ

### 次のステップ

- 高度なrevertテクニック
- 複雑なマージの取り消し
- チーム開発でのrevert運用

### おすすめの学習リソース

- [Git公式ドキュメント](https://git-scm.com/docs/git-revert)
- [Pro Git Book](https://git-scm.com/book/ja/v2)
- [GitHub Docs](https://docs.github.com/ja)

### コミュニティ情報

- [Stack Overflow](https://stackoverflow.com/questions/tagged/git)
- [GitHub Discussions](https://github.com/git/git/discussions)
- [GitHub Community](https://github.community/)
