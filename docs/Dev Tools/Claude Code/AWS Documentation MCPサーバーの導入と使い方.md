# AWS Documentation MCPサーバーの導入と使い方

AWSのドキュメントは膨大で、目的のページにたどり着くまでブラウザとClaude Codeを何度も行き来することがある。「このAPIの制限はいくつだっけ」「このサービスは東京リージョンで使えるんだっけ」といった疑問が出るたびにコンテキストが途切れる。

AWS Documentation MCPサーバーを導入すると、Claude CodeがAWSの公式ドキュメントを直接検索・参照できるようになる。ブラウザを開かなくても、会話の流れを保ったままAWSの情報を引き出せる。

## できること

| ツール | 用途 |
|--------|------|
| `search_documentation` | キーワードでAWSドキュメントを検索 |
| `read_documentation` | ドキュメントURLの内容をMarkdownで取得 |
| `read_sections` | 特定セクションだけを抽出 |
| `recommend` | 関連ページを発見（新機能情報の確認にも使える） |

## セットアップ

### 前提条件

`uv`（Pythonパッケージ管理ツール）が必要。

```bash
# uvがなければインストール
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### MCPサーバーを登録

```bash
claude mcp add awslabs.aws-documentation-mcp-server \
  -e FASTMCP_LOG_LEVEL=ERROR \
  -e AWS_DOCUMENTATION_PARTITION=aws \
  -- uvx awslabs.aws-documentation-mcp-server@latest \
  --scope user
```

`--scope user` をつけると全プロジェクトで使える。カレントプロジェクトだけに限定したい場合は外す。

### 確認

```bash
claude mcp list
```

`awslabs.aws-documentation-mcp-server` が一覧に出ていればOK。

### 設定ファイルでの登録（`.mcp.json` を使う場合）

プロジェクトルートの `.mcp.json` に直接書いてもよい（チームで共有する場合など）。

```json
{
  "mcpServers": {
    "awslabs.aws-documentation-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_DOCUMENTATION_PARTITION": "aws"
      }
    }
  }
}
```

## 使い方

Claude Codeを起動すれば自動的に利用可能になる。あとは普通に聞くだけ。

```
S3のバケット命名規則を教えて
↓
（公式ドキュメントを検索して、出典URLとともに回答）
```

```
Lambda の同時実行数の制限はいくつ？
↓
（ドキュメントから該当箇所を取得して回答）
```

```
CloudTrailの最新機能を確認して
↓
（recommendツールでNewセクションを参照して回答）
```

記事を書くときにも使いやすい。「この記事の参考リンクを公式ドキュメントから探して」と頼めば、`## 参考` セクションに貼るURLを一緒に探してくれる。

## 中国リージョンを使う場合

`AWS_DOCUMENTATION_PARTITION` を `aws-cn` に変更し、`get_available_services` ツールで中国リージョンの対応サービスを確認できる。

```bash
claude mcp add awslabs.aws-documentation-mcp-server \
  -e FASTMCP_LOG_LEVEL=ERROR \
  -e AWS_DOCUMENTATION_PARTITION=aws-cn \
  -- uvx awslabs.aws-documentation-mcp-server@latest \
  --scope user
```

## 参考

- [AWS Documentation MCP Server - awslabs公式ドキュメント](https://awslabs.github.io/mcp/servers/aws-documentation-mcp-server)
- [awslabs/mcp - GitHub](https://github.com/awslabs/mcp)
- [uv - Python package installer](https://docs.astral.sh/uv/)
