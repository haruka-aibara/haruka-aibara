<!-- Space: harukaaibarapublic -->
<!-- Title: Atlassian API トークン発行手順 -->

# Atlassian API トークン発行手順

mark 等のツールで GitHub から Confluence に自動同期する際に必要な API トークンの発行手順。

- 公式ドキュメント: https://support.atlassian.com/ja/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/
- API トークン管理ページ: https://id.atlassian.com/manage-profile/security/api-tokens

---

## 手順

### 1. API トークン管理ページを開く

https://id.atlassian.com/manage-profile/security/api-tokens にアクセスする。

### 2. 「スコープ付きAPIトークンを作成」をクリック

通常の「APIトークンを作成」はアカウント全体に権限が及ぶ。CI/CD に使うトークンは **スコープ付き** で権限を絞っておくこと。

### 3. トークン名・有効期限・スコープを設定する

| 項目 | 設定値 |
|---|---|
| ラベル | 用途がわかる名前（例: `github-actions-confluence-sync`） |
| 有効期限 | 1〜365日（無期限は選べない） |
| アプリ | Confluence |
| スコープ | 以下の classic スコープを選択 |

**選択するスコープ（classic）:**

| スコープ | 用途 |
|---|---|
| `read:confluence-content.all` | ページの存在確認・バージョン取得 |
| `write:confluence-content` | ページ作成・更新・画像添付 |
| `read:confluence-space.summary` | スペース情報の読み取り |

granular スコープはより細かく絞れるが、mark が使う API エンドポイントに合わせて選ぶ必要があり煩雑。classic スコープで十分。

### 4. 「作成」をクリックしてトークンをコピーする

**このダイアログを閉じると二度と表示されない。** 必ずこのタイミングでコピーしてパスワードマネージャー等に保存すること。

---

## GitHub Secrets への登録

リポジトリ → Settings → Secrets and variables → Actions → New repository secret

| Secret 名 | 値 |
|---|---|
| `CONFLUENCE_USER` | Atlassian アカウントのメールアドレス |
| `CONFLUENCE_API_TOKEN` | 発行した API トークン |
| `CONFLUENCE_BASE_URL` | `https://yourorg.atlassian.net/wiki` |
