# Jira MCPサーバーの導入と使い方

## なぜ必要か

Jiraのチケット操作は地味に手間がかかる。スプリントのチケットを確認しながらコードを書いているとき、ブラウザとエディタを行き来するのは無駄が多い。

Jira MCPサーバーを導入すると、Claude Codeの会話の中でJiraのチケット検索・作成・更新ができるようになる。「今スプリントの未着手チケット一覧」「このバグのチケット作って」を会話で完結できる。

## Jira MCPサーバーでできること

| カテゴリ | できること |
|----------|-----------|
| 課題（Issue） | 検索・作成・更新・コメント追加 |
| スプリント | 現在のスプリントの課題一覧確認 |
| プロジェクト | プロジェクト・ボードの情報取得 |
| JQL | JQLクエリを自然言語で実行 |

## セットアップ

### 方法1：公式リモートMCPサーバー（推奨）

Atlassian が公式に提供するリモートMCPサーバーを使う方法。API トークン不要で OAuth 認証。

```bash
claude mcp add --transport sse jira https://mcp.atlassian.com/v1/sse
```

**`--scope user` をつけるとすべてのプロジェクトで使えるようになる：**

```bash
claude mcp add --scope user --transport sse jira https://mcp.atlassian.com/v1/sse
```

初回接続時にブラウザが開き、Atlassian アカウントで OAuth 認証を求められる。

### 方法2：API トークン方式（ローカルサーバー）

SSE が使えない環境や、API トークンで認証を管理したい場合の代替手段。Node.js が必要。

**1. Atlassian API トークンを作成**

[Atlassian Account → Security → API tokens](https://id.atlassian.com/manage-profile/security/api-tokens) でトークンを作成（再表示されないのでコピーして保管）。

**2. MCPサーバーを登録**

```bash
claude mcp add --scope user jira \
  -e ATLASSIAN_URL=https://your-domain.atlassian.net \
  -e ATLASSIAN_USER_EMAIL=your@email.com \
  -e ATLASSIAN_API_TOKEN=your_token \
  -- npx -y @atlassian/mcp
```

`your-domain` は自分のJiraのURLのサブドメイン部分。

### 確認

```bash
claude mcp list
claude mcp get jira
```

`jira` が一覧に出ていればOK。

## 使い方

Claude Codeを起動すると、自動的にJira MCPサーバーが利用可能になる。

```
今スプリントの自分のチケット一覧を見せて
↓
（JiraのAPIを叩いてチケット一覧を返してくれる）
```

```
「ログイン時にエラーが出る」というバグチケットを PROJECT-X に作って
↓
（チケットを作成してURLを返してくれる）
```

```
PROJECT-123 のステータスを「進行中」に変えて
↓
（チケットのステータスを更新してくれる）
```

## セキュリティ上の注意

- APIトークンをコードや設定ファイルにハードコードしない
- トークンが漏洩した場合は [Atlassian Account → API tokens](https://id.atlassian.com/manage-profile/security/api-tokens) で即座に無効化
- Confluenceも同じAPIトークンで操作できるため、権限範囲に注意

## 設定ファイルの場所

`--scope user` で登録した場合、設定は `~/.claude/mcp.json` に保存される。

**方法1（リモートSSE）の場合：**

```json
{
  "mcpServers": {
    "jira": {
      "type": "sse",
      "url": "https://mcp.atlassian.com/v1/sse"
    }
  }
}
```

**方法2（APIトークン）の場合：**

```json
{
  "mcpServers": {
    "jira": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@atlassian/mcp"],
      "env": {
        "ATLASSIAN_URL": "https://your-domain.atlassian.net",
        "ATLASSIAN_USER_EMAIL": "your@email.com",
        "ATLASSIAN_API_TOKEN": "your_token"
      }
    }
  }
}
```

## 参考

- [Using the Atlassian Remote MCP Server (beta) - Atlassian Community](https://community.atlassian.com/forums/Atlassian-Platform-articles/Using-the-Atlassian-Remote-MCP-Server-beta/ba-p/3005104)
- [atlassian/mcp npm パッケージ](https://www.npmjs.com/package/@atlassian/mcp)
- [Atlassian API トークン管理](https://id.atlassian.com/manage-profile/security/api-tokens)
- [Claude Code MCP ドキュメント](https://docs.anthropic.com/ja/docs/claude-code/mcp)
