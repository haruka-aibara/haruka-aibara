# git reset --hard

## はじめに

「すべての変更を完全に取り消したい...」
「作業ディレクトリをクリーンな状態に戻したい...」
「誤った変更を完全に破棄したい...」

Gitで変更を完全に取り消す際に、このような悩みを抱えたことはありませんか？git reset --hardは、コミット、ステージング、作業ディレクトリの変更をすべて取り消す強力なコマンドです。この記事では、git reset --hardの使い方と注意点について解説します。

## ざっくり理解しよう

git reset --hardの重要なポイントは以下の3つです：

1. **完全な変更の取り消し**
   - コミットの取り消し
   - ステージングの取り消し
   - 作業ディレクトリの変更の破棄

2. **注意が必要な操作**
   - 変更は完全に失われる
   - 復元が困難
   - 公開済みの変更には使用しない

3. **使用するタイミング**
   - 実験的な変更の破棄
   - 誤った変更の完全な取り消し
   - クリーンな状態への復帰

## 実際の使い方

### よくある使用シーン

1. **実験的な変更の破棄**
   - 試行錯誤した変更の破棄
   - 失敗した実装の取り消し
   - 不要な変更の削除

2. **誤った変更の取り消し**
   - 誤って追加したファイルの削除
   - 誤った修正の取り消し
   - 不要なコミットの削除

3. **クリーンな状態への復帰**
   - 作業ディレクトリのクリーンアップ
   - 未追跡ファイルの削除
   - リポジトリの初期化

## 手を動かしてみよう

### 基本的な使い方

1. 直前のコミットを取り消す
```bash
git reset --hard HEAD~1
```

2. 特定のコミットまで戻る
```bash
git reset --hard <commit-hash>
```

3. すべての変更を取り消す
```bash
git reset --hard HEAD
```

## 実践的なサンプル

### コミットの取り消し

```bash
# 直前のコミットを取り消す
git reset --hard HEAD~1

# 特定のコミットまで戻る
git reset --hard a1b2c3d

# 複数のコミットを取り消す
git reset --hard HEAD~3
```

### 作業ディレクトリのクリーンアップ

```bash
# すべての変更を取り消す
git reset --hard HEAD

# 未追跡ファイルも削除
git reset --hard HEAD && git clean -fd

# 特定のファイルの変更を取り消す
git checkout -- path/to/file
```

### 誤った変更の取り消し

```bash
# 誤ってステージングした変更を取り消す
git reset --hard HEAD

# 誤ってコミットした変更を取り消す
git reset --hard HEAD~1

# 誤って追加したファイルを削除
git clean -f
```

## 困ったときは

### よくあるトラブルと解決方法

1. **誤ったreset**
   - 問題：意図しない変更の取り消し
   - 解決：`git reflog`で履歴を確認し、`git reset --hard`で復元

2. **変更の完全な紛失**
   - 問題：必要な変更が失われた
   - 解決：バックアップから復元

3. **公開済みの変更のreset**
   - 問題：チームメンバーに影響を与える
   - 解決：`git revert`を使用する

## もっと知りたい人へ

### 次のステップ

- 高度なreset --hardテクニック
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
