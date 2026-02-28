<!-- Space: harukaaibarapublic -->
<!-- Parent: GitHub-Confluence同期 -->
<!-- Title: Atlassian API トークン発行手順 -->

# Atlassian API トークン発行手順

mark 等のツールで GitHub から Confluence に自動同期する際に必要な API トークンの発行手順。

- 公式ドキュメント: https://support.atlassian.com/ja/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/
- API トークン管理ページ: https://id.atlassian.com/manage-profile/security/api-tokens

---

## スコープ付き API トークンは mark で使えない

Atlassian にはスコープ付き API トークン（権限を絞ったトークン）があるが、**mark は Basic 認証前提のため動作しない**。通常の（スコープなし）API トークンを使う必要がある。

### 権限を絞りたい場合はサービスアカウントで対応する

通常トークンはそのユーザーアカウントの権限をそのまま持つ。管理者アカウントのトークンを使うと Confluence 全体に権限が及んでしまうため、**専用のサービスアカウントを作り、最小権限を付与した上でそのアカウントのトークンを発行する**。

| 手順 | 内容 |
|---|---|
| 1 | 専用ユーザーを作成（例: `github-actions@yourorg.com`） |
| 2 | そのユーザーに対象 Space の Read + Create Pages 権限のみ付与 |
| 3 | そのユーザーでログインし、API トークンを発行 |

→ トークン自体はスコープなしでも、ユーザーが持つ権限しか使えないため実質的に最小権限になる。

---

## 手順

### 1. API トークン管理ページを開く

https://id.atlassian.com/manage-profile/security/api-tokens にアクセスする。
サービスアカウントを使う場合はそのアカウントでログインしてから操作すること。

### 2. 「APIトークンを作成」をクリック

スコープ付きではなく通常の「APIトークンを作成」を選ぶ。

### 3. トークン名と有効期限を設定する

| 項目 | 設定値 |
|---|---|
| ラベル | 用途がわかる名前（例: `github-actions-confluence-sync`） |
| 有効期限 | 1〜365日（無期限は選べない） |

### 4. 「作成」をクリックしてトークンをコピーする

**このダイアログを閉じると二度と表示されない。** 必ずこのタイミングでコピーしてパスワードマネージャー等に保存すること。

---

## GitHub Secrets への登録

リポジトリ → Settings → Secrets and variables → Actions → New repository secret

| Secret 名 | 値 |
|---|---|
| `CONFLUENCE_USER` | サービスアカウントのメールアドレス |
| `CONFLUENCE_API_TOKEN` | 発行した API トークン |
| `CONFLUENCE_BASE_URL` | `https://yourorg.atlassian.net/wiki` |
