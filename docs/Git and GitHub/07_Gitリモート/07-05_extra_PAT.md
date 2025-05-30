# GitHub Personal Access Token (PAT)

GitHub Personal Access Token（PAT）は、GitHub APIやコマンドラインでの認証に使用する安全な認証方法です。

## Personal Access Tokenとは

PATはパスワードの代わりに使用できるトークンで、特定の権限（スコープ）を設定して安全にGitHubリポジトリにアクセスできます。

## PATの作成方法

1. GitHubにログインして、右上のプロフィールアイコンをクリックします
2. 「Settings」を選択します
3. 左側のサイドバーから「Developer settings」をクリックします
4. 「Personal access tokens」→「Tokens (classic)」を選択します
5. 「Generate new token」をクリックします
6. トークンの説明（Note）を入力します
7. トークンの有効期限を設定します
8. 必要な権限（スコープ）を選択します
   - repo: リポジトリへのフルアクセス
   - workflow: ワークフローファイルの操作
   - read:org: 組織情報の読み取り
   - 他にも多数のスコープがあります
9. 「Generate token」をクリックします
10. 生成されたトークンをコピーして安全な場所に保存します（この画面を離れると二度と表示されません）

## PATの使用方法

### コマンドラインでの使用

```bash
# クローン時にユーザー名とPATを使用
git clone https://ユーザー名:PAT@github.com/ユーザー名/リポジトリ名.git

# または既存のリモートURLを更新
git remote set-url origin https://ユーザー名:PAT@github.com/ユーザー名/リポジトリ名.git
```

### 認証情報の保存（推奨）

```bash
# 認証情報をキャッシュに保存
git config --global credential.helper cache

# または認証情報をディスクに保存（Windows）
git config --global credential.helper wincred

# macOSの場合
git config --global credential.helper osxkeychain

# Linuxの場合
git config --global credential.helper store
```

## セキュリティ上の注意点

- PATはパスワードと同様に扱い、他人に共有しないでください
- 必要最小限の権限（スコープ）だけを付与しましょう
- 有効期限を設定して定期的に更新することをお勧めします
- 不要になったPATは削除しましょう
- 誤ってPATを公開してしまった場合は、すぐに無効化して新しいトークンを作成してください

## トラブルシューティング

- 「Authentication failed」エラーが出た場合、PATが有効か確認しましょう
- スコープ不足の場合は、適切な権限を持つ新しいPATを作成してください
- 「Git push」や「Git pull」でHTTPSパスワードを求められたら、パスワードの代わりにPATを入力します
