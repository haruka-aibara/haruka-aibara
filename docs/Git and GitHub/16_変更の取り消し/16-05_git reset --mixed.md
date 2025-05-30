# git reset --mixed

## はじめに

「コミットを取り消したいけど、変更は残したい...」
「ステージングを取り消したい...」
「変更を再構成したい...」

Gitで変更を取り消す際に、このような悩みを抱えたことはありませんか？git reset --mixedは、コミットとステージングを取り消しつつ、作業ディレクトリの変更は保持する便利なオプションです。この記事では、git reset --mixedの使い方と実践的な活用方法について解説します。

## ざっくり理解しよう

git reset --mixedの重要なポイントは以下の3つです：

1. **安全な変更の取り消し**
   - コミットの取り消し
   - ステージングの取り消し
   - 作業ディレクトリの変更は保持

2. **柔軟な変更の再構成**
   - 変更の再ステージング
   - コミットの分割
   - 変更の整理

3. **デフォルトの動作**
   - 最も一般的な使用法
   - 安全な操作
   - 変更の保持

## 実際の使い方

### よくある使用シーン

1. **コミットの取り消し**
   - 誤ったコミットの修正
   - コミットの分割
   - コミットの統合

2. **ステージングの取り消し**
   - 誤ってステージングした変更の取り消し
   - ステージングの整理
   - 変更の再構成

3. **変更の再構成**
   - 変更の論理的な整理
   - コミットの整理
   - レビューしやすい単位への分割

## 手を動かしてみよう

### 基本的な使い方

1. 直前のコミットを取り消す
```bash
git reset HEAD~1
```

2. 特定のコミットまで戻る
```bash
git reset <commit-hash>
```

3. ステージングを取り消す
```bash
git reset HEAD
```

## 実践的なサンプル

### コミットの取り消し

```bash
# 直前のコミットを取り消す
git reset HEAD~1

# 特定のコミットまで戻る
git reset a1b2c3d

# 複数のコミットを取り消す
git reset HEAD~3
```

### ステージングの取り消し

```bash
# 特定のファイルのステージングを取り消す
git reset HEAD path/to/file

# すべてのステージングを取り消す
git reset HEAD

# ステージングを取り消して変更を確認
git status
```

### 変更の再構成

```bash
# コミットを取り消して変更を再構成
git reset HEAD~1

# 変更を確認
git status

# 変更を再ステージング
git add path/to/file1
git commit -m "機能Aの実装"

git add path/to/file2
git commit -m "機能Bの実装"
```

## 困ったときは

### よくあるトラブルと解決方法

1. **誤ったreset**
   - 問題：意図しない変更の取り消し
   - 解決：`git reflog`で履歴を確認し、`git reset`で復元

2. **変更の紛失**
   - 問題：変更が失われたように見える
   - 解決：`git status`で未ステージの変更を確認

3. **公開済みの変更のreset**
   - 問題：チームメンバーに影響を与える
   - 解決：`git revert`を使用する

## もっと知りたい人へ

### 次のステップ

- 高度なreset --mixedテクニック
- リベースとの組み合わせ
- チーム開発での運用

### おすすめの学習リソース

- [Git公式ドキュメント](https://git-scm.com/docs/git-reset)
- [Pro Git Book](https://git-scm.com/book/ja/v2)
- [GitHub Docs](https://docs.github.com/ja)

### コミュニティ情報

- [Stack Overflow](https://stackoverflow.com/questions/tagged/git)
- [GitHub Discussions](https://github.com/git/git/discussions)
- [GitHub Community](https://github.community/)
