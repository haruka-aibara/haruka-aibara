# 変更の取り消し

Gitでは、コミットした変更を取り消すための複数の方法が用意されています。例えば、誤ってコミットしてしまった変更を元に戻したり、特定の変更を打ち消す新しいコミットを作成したりすることができます。これらの機能を適切に使い分けることで、安全に変更を管理することができます。

このセクションでは、以下の主要な変更の取り消し方法を学びます：

1. **git revert**
   - 変更の打ち消し
   - 新しいコミットの作成
   - 履歴の保持

2. **git reset**
   - リセットの基本
   - ソフトリセット
   - ハードリセット
   - ミックスドリセット

3. **リセットの活用**
   - ステージングの取り消し
   - コミットの修正
   - 変更の巻き戻し

各トピックの詳細は、以下のファイルで詳しく説明しています：

### 基本操作
- [16-01_git revert.md](16-01_git revert.md) - 変更の打ち消しと新しいコミットの作成
- [16-02_git reset.md](16-02_git reset.md) - リセットの基本概念と使用方法

### リセットの種類
- [16-03_git reset --soft.md](16-03_git reset --soft.md) - ソフトリセットの使用方法
- [16-04_git reset --hard.md](16-04_git reset --hard.md) - ハードリセットの使用方法
- [16-05_git reset --mixed.md](16-05_git reset --mixed.md) - ミックスドリセットの使用方法

## 学習リソース

### 公式ドキュメント
- [Undoing Changes](https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified) - Git公式の変更取り消しガイド

### 記事
- [Undo Anything in Git](https://github.blog/open-source/git/how-to-undo-almost-anything-with-git/) - GitHubによる変更取り消しの解説
- [Undoing Changes in Git](https://www.atlassian.com/git/tutorials/undoing-changes) - Atlassianによる変更取り消しの解説 
