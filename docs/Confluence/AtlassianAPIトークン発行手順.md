<!-- Space: harukaaibarapublic -->
<!-- Parent: GitHub-Confluence同期 -->
<!-- Title: Atlassian API トークン発行手順 -->

# Atlassian API トークン発行手順

mark 等のツールで GitHub から Confluence に自動同期する際に必要な API トークンの発行手順。

- 公式ドキュメント: https://support.atlassian.com/ja/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/
- API トークン管理ページ: https://id.atlassian.com/manage-profile/security/api-tokens

---

## スコープ付き API トークンを使う場合（推奨）

スコープ付きトークンは mark でも使えるが、**Base URL を Atlassian API Gateway 経由に変える必要がある**。

通常の `https://yourorg.atlassian.net/wiki` では 401 になる。代わりに Cloud ID を含む URL を使う：

```
https://api.atlassian.com/ex/confluence/<Cloud_ID>/wiki
```

> **情報源**: mark の GitHub Issues での実際の動作報告より。通常 URL でスコープ付きトークンを使うと 401/403 になることが複数のユーザーから報告されており、API Gateway URL への変更で解決している。
> - https://github.com/kovetskiy/mark/issues/259
> - https://github.com/kovetskiy/mark/issues/493

### Cloud ID の調べ方

```bash
curl https://yourorg.atlassian.net/_edge/tenant_info
# → {"cloudId":"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",...}
```

### 選択するスコープ（classic）

| スコープ | 用途 |
|---|---|
| `read:confluence-content.all` | ページの存在確認・バージョン取得 |
| `write:confluence-content` | ページ作成・更新・画像添付 |
| `read:confluence-space.summary` | スペース情報の読み取り |

---

## スコープなしトークン + サービスアカウントを使う場合

スコープ付きを使わない場合、**専用のサービスアカウントを作り最小権限を付与した上でそのアカウントのトークンを発行する**方法で権限を絞る。

| 手順 | 内容 |
|---|---|
| 1 | 専用ユーザーを作成（例: `github-actions@yourorg.com`） |
| 2 | そのユーザーに対象 Space の Read + Create Pages 権限のみ付与 |
| 3 | そのユーザーでログインし、通常の API トークンを発行 |

Base URL は通常の `https://yourorg.atlassian.net/wiki` のままで動作する。

---

## 手順

### 1. API トークン管理ページを開く

https://id.atlassian.com/manage-profile/security/api-tokens にアクセスする。

### 2. トークンの種類を選ぶ

- 権限を細かく絞りたい → 「スコープ付きAPIトークンを作成」
- サービスアカウント運用にする → 「APIトークンを作成」

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

| Secret 名 | スコープ付きトークンの場合 | スコープなしトークンの場合 |
|---|---|---|
| `CONFLUENCE_USER` | メールアドレス | サービスアカウントのメールアドレス |
| `CONFLUENCE_API_TOKEN` | 発行したスコープ付きトークン | 発行したトークン |
| `CONFLUENCE_BASE_URL` | `https://api.atlassian.com/ex/confluence/<Cloud_ID>/wiki` | `https://yourorg.atlassian.net/wiki` |
