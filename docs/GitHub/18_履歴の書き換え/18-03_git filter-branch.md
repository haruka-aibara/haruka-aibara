# Git filter-branchで履歴を書き換える

## はじめに

「過去のコミットに誤ったメールアドレスが含まれている」「ユーザー名を変更したので、過去のコミットも更新したい」そんな悩みはありませんか？

Git filter-branchを使えば、リポジトリの履歴を大規模に書き換えることができます。この記事では、特にコミットしたユーザー情報の変更方法に焦点を当てて解説します。

> **注意**: Git filter-branchは複雑で危険な操作を含む可能性があります。より安全で効率的な代替手段として、[git filter-repo](https://github.com/newren/git-filter-repo)の使用が推奨されています。

## ざっくり理解しよう

Git filter-branchの重要なポイントは以下の3つです：

1. **履歴の一括変更**
   - リポジトリ全体の履歴を一度に書き換え可能
   - コミットメッセージ、作者情報、ファイル内容など様々な要素を変更可能
   - 元のコミット時間やマージ情報は保持されます

2. **強力なフィルタリング機能**
   - 条件に基づいて特定のコミットのみを変更可能
   - 複数の条件を組み合わせた複雑な変更も可能
   - ツリーの内容（ファイルの削除やPerlスクリプトの実行など）も変更可能

3. **慎重な使用が必要**
   - 履歴の書き換えは取り消しが難しい
   - チーム開発では特に注意が必要
   - 指定したブランチのみが書き換えられます

## 実際の使い方

### よくある使用シーン

1. **ユーザー情報の更新**
   - メールアドレスの変更
   - ユーザー名の変更
   - 組織名の変更

2. **機密情報の削除**
   - 誤ってコミットしたパスワードの削除
   - 機密ファイルの履歴からの完全削除
   - センシティブなデータの一括削除

3. **リポジトリの整理**
   - 不要なファイルの履歴からの削除
   - コミットメッセージの一括修正
   - 大規模リポジトリの最適化

## 手を動かしてみよう

### ユーザー情報の変更

```bash
# 基本的な構文
git filter-branch --force --env-filter '
    # 変更したい情報を条件分岐で指定
    if [ "$GIT_AUTHOR_EMAIL" = "OLD_EMAIL" ];
    then
        GIT_AUTHOR_EMAIL="NEW_EMAIL";
    fi
' -- --all
```

### 具体的な例

```bash
git filter-branch --force --env-filter '
    # 作者名の変更
    if [ "$GIT_AUTHOR_NAME" = "OLD_NAME" ];
    then
        GIT_AUTHOR_NAME="NEW_NAME";
    fi
    
    # メールアドレスの変更
    if [ "$GIT_AUTHOR_EMAIL" = "OLD_EMAIL_ADDRESS" ];
    then
        GIT_AUTHOR_EMAIL="NEW_EMAIL_ADDRESS";
    fi
    
    # コミッター名の変更
    if [ "$GIT_COMMITTER_NAME" = "OLD_NAME" ];
    then
        GIT_COMMITTER_NAME="NEW_NAME";
    fi
    
    # コミッターのメールアドレス変更
    if [ "$GIT_COMMITTER_EMAIL" = "OLD_EMAIL_ADDRESS" ];
    then
        GIT_COMMITTER_EMAIL="NEW_EMAIL_ADDRESS";
    fi
' -- --all
```

## 実践的なサンプル

### 複数の条件を組み合わせる

```bash
# 特定の期間のコミットのみ変更
git filter-branch --force --env-filter '
    if [ "$GIT_AUTHOR_DATE" > "2023-01-01" ] && [ "$GIT_AUTHOR_DATE" < "2023-12-31" ];
    then
        GIT_AUTHOR_EMAIL="NEW_EMAIL";
        GIT_COMMITTER_EMAIL="NEW_EMAIL";
    fi
' -- --all
```

## 困ったときは

### よくあるトラブルと解決方法

1. **変更が反映されない場合**
```bash
# 強制的に実行
git filter-branch --force --env-filter '...' -- --all
```

2. **変更を取り消したい場合**
```bash
# リファレンスログから復元
git reflog
git reset --hard HEAD@{1}
```

### 予防するためのコツ
- 実行前に必ずバックアップを取る
- 変更内容を小さな単位でテスト
- チーム開発の場合は事前に周知する
- 可能であればgit filter-repoの使用を検討する

## もっと知りたい人へ

### 次のステップ
- より高度なフィルタリング条件の設定
- サブモジュールを含むリポジトリの処理
- 大規模リポジトリでの最適な使用方法
- git filter-repoへの移行を検討

### おすすめの学習リソース
- [Git公式ドキュメント](https://git-scm.com/docs/git-filter-branch)
- [GitHub Docs - センシティブなデータの削除](https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [git filter-repo公式リポジトリ](https://github.com/newren/git-filter-repo)

### コミュニティ情報
- Stack Overflowの`git-filter-branch`タグ
- GitHub Discussionsでの履歴書き換え関連の議論
- git filter-repoのGitHub Issues
