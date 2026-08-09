# git reset

## はじめに

「コミットを取り消したいけど、履歴も消したい...」
「ステージングした変更を取り消したい...」
「作業ディレクトリをクリーンな状態に戻したい...」

Gitで変更を取り消す際に、このような悩みを抱えたことはありませんか？git resetコマンドは、HEADの位置を変更し、作業ディレクトリやステージングエリアの状態を制御する強力なツールです。この記事では、git resetの使い方と実践的な活用方法について解説します。

## ざっくり理解しよう

git resetの重要なポイントは以下の3つです：

1. **HEADの移動**
   - コミット履歴の位置を変更
   - ブランチの先端を移動
   - 履歴の書き換え

2. **3つのモード**
   - soft: コミットのみ取り消し
   - mixed: コミットとステージングを取り消し
   - hard: すべての変更を取り消し

3. **注意が必要な操作**
   - 公開済みの変更には使用しない
   - チーム開発での使用は慎重に
   - バックアップを取ってから実行

## 実際の使い方

### よくある使用シーン

1. **コミットの取り消し**
   - 誤ったコミットの修正
   - コミットメッセージの修正
   - コミットの分割

2. **ステージングの取り消し**
   - 誤ってステージングした変更の取り消し
   - ステージングの整理
   - 変更の再構成

3. **作業ディレクトリのクリーンアップ**
   - 未追跡ファイルの削除
   - 変更の破棄
   - クリーンな状態への復帰

## 手を動かしてみよう

### 基本的な使い方

1. コミットの取り消し（soft）
```bash
git reset --soft HEAD~1
```

2. ステージングの取り消し（mixed）
```bash
git reset HEAD~1
```

3. すべての変更の取り消し（hard）
```bash
git reset --hard HEAD~1
```

## 実践的なサンプル

### コミットの取り消し

```bash
# 直前のコミットを取り消し（変更はステージングされたまま）
git reset --soft HEAD~1

# 直前のコミットを取り消し（変更はステージングされていない）
git reset HEAD~1

# 直前のコミットを取り消し（変更も破棄）
git reset --hard HEAD~1
```

### ステージングの取り消し

```bash
# 特定のファイルのステージングを取り消し
git reset HEAD path/to/file

# すべてのステージングを取り消し
git reset HEAD

# ステージングを取り消して変更も破棄
git reset --hard HEAD
```

### 作業ディレクトリのクリーンアップ

```bash
# 未追跡ファイルの削除
git clean -f

# 未追跡ディレクトリの削除
git clean -fd

# 変更の破棄と未追跡ファイルの削除
git reset --hard HEAD && git clean -fd
```

## 困ったときは

### よくあるトラブルと解決方法

1. **誤ったreset**
   - 問題：意図しない変更の取り消し
   - 解決：`git reflog`で履歴を確認し、`git reset`で復元

2. **公開済みの変更のreset**
   - 問題：チームメンバーに影響を与える
   - 解決：`git revert`を使用する

3. **未追跡ファイルの削除**
   - 問題：必要なファイルが削除された
   - 解決：バックアップから復元

## もっと知りたい人へ

### 次のステップ

- 高度なresetテクニック
- リベースとの組み合わせ
- チーム開発でのreset運用

### おすすめの学習リソース

- [Git公式ドキュメント](https://git-scm.com/docs/git-reset)
- [Pro Git Book](https://git-scm.com/book/ja/v2)
- [GitHub Docs](https://docs.github.com/ja)

### コミュニティ情報

- [Stack Overflow](https://stackoverflow.com/questions/tagged/git)
- [GitHub Discussions](https://github.com/git/git/discussions)
- [GitHub Community](https://github.community/)
