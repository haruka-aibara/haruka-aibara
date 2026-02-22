# GitHub MCPサーバーの導入と使い方

## MCPとは

MCP（Model Context Protocol）はAnthropicが策定したオープンプロトコル。AIアシスタントが外部ツールやサービスと会話形式でやり取りするための仕組み。

Claude Codeはデフォルトでファイル操作・コマンド実行・検索などができるが、MCPサーバーを追加することで**GitHubのAPIを自然言語で操作**できるようになる。

## GitHub MCPサーバーでできること

| カテゴリ | できること |
|----------|-----------|
| リポジトリ | コード閲覧、ファイル検索、コミット確認 |
| Issue / PR | 作成・更新・クローズ、コメント |
| CI/CD | GitHub Actionsの実行状況確認、失敗分析 |
| セキュリティ | Dependabotアラート確認、コードスキャン結果 |
| 通知 | 通知の確認・管理 |

コマンドを毎回タイプしなくても「このブランチのPR作って」「直近のIssue一覧見せて」といった形で操作できる。

## セットアップ

### 1. GitHub Personal Access Token (PAT) を作成

[GitHub Settings → Fine-grained tokens](https://github.com/settings/personal-access-tokens/new) で新しいトークンを作成。

**必要な権限（最小構成）：**
- `Contents` → Read and write（ファイル操作する場合）
- `Issues` → Read and write
- `Pull requests` → Read and write
- `Actions` → Read（CI確認する場合）
- `Metadata` → Read（必須）

用途に合わせて追加する。作ったトークンはコピーして安全な場所に保管（再表示されない）。

### 2. MCPサーバーを登録

**リモートサーバー方式（推奨）：**
GitHubが公式にホストしているサーバーを使う。Dockerなど不要で一番シンプル。

```bash
claude mcp add-json github '{"type":"http","url":"https://api.githubcopilot.com/mcp","headers":{"Authorization":"Bearer YOUR_GITHUB_PAT"}}' --scope user
```

`YOUR_GITHUB_PAT` を実際のトークンに置き換える。`--scope user` をつけるとすべてのプロジェクトで使えるようになる（つけないとカレントプロジェクトのみ）。

**Docker方式（ローカルサーバー）：**
Dockerが使える環境向け。GitHub Enterprise Serverを使っている場合もこちら。

```bash
claude mcp add github \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=YOUR_GITHUB_PAT \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
```

### 3. 確認

```bash
claude mcp list
claude mcp get github
```

`github` が一覧に出ていればOK。

## 使い方

Claude Codeを起動すると、自動的にGitHub MCPサーバーが利用可能になる。あとは普通に会話するだけ。

```
このリポジトリの直近5件のIssue見せて
↓
（GitHub APIを叩いてIssue一覧を返してくれる）
```

```
mainブランチへのPRを作って。タイトルは「◯◯機能の追加」で
↓
（PR作成してURLを返してくれる）
```

```
最後のコミットのCI結果は？
↓
（GitHub Actionsの実行結果を確認してくれる）
```

## セキュリティ上の注意

- PATをコードや設定ファイルにハードコードしない（`.env` も `.gitignore` に入れる）
- 必要最小限の権限だけ付与する（Fine-grained tokenを使う理由）
- 漏洩した場合はすぐに [GitHub Settings → Tokens](https://github.com/settings/tokens) で無効化

## 設定ファイルの場所

`--scope user` で登録した場合、設定は `~/.claude/mcp.json` に保存される。直接編集することも可能。

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": {
        "Authorization": "Bearer ghp_xxxxxxxxxxxx"
      }
    }
  }
}
```

## 参考

- [GitHub MCP Server 公式リポジトリ](https://github.com/github/github-mcp-server)
- [Claude Code MCP ドキュメント](https://code.claude.com/docs/en/mcp)
