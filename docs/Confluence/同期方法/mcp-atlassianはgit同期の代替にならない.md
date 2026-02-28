<!-- Space: harukaaibarapublic -->
<!-- Parent: 同期方法 -->
<!-- Title: mcp-atlassian は git 同期の代替にならない -->

# mcp-atlassian は git 同期の代替にならない

## きっかけ

「mark + GitHub Actions より [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian) のほうがよくない？」と思って調べた結果のメモ。

## sooperset/mcp-atlassian とは

Confluence と Jira を操作できるコミュニティ製 MCP サーバー。Claude Code や Cursor などの AI クライアントから自然言語で操作できる。

```
confluence_search    # CQL で検索
confluence_get_page  # ページ取得
confluence_create_page  # ページ作成
confluence_update_page  # ページ更新
confluence_add_comment  # コメント追加
（計 65 ツール）
```

Cloud / Server / Data Center 両対応で、Atlassian 公式の Rovo MCP とは別の OSS。

## なぜ git 同期の代替にならないか

この 2 つは**目的が根本的に違う**。

| | mark + GitHub Actions | mcp-atlassian |
|---|---|---|
| トリガー | git push で**自動** | 人間が AI に**手動で指示** |
| Markdown の位置づけ | Single Source of Truth | 関係ない（Confluence を直接操作） |
| 運用コスト | push するだけ | 毎回 Claude に指示が必要 |
| 用途 | ドキュメントの継続的デリバリー | アドホックな操作・検索 |

MCP サーバーは「AI アシスタントが Confluence を読み書きできるようにする」ためのもの。push 自動同期の仕組みを持たないため、git が正本というワークフローとは相性が悪い。

具体的には：

- push しても何も起きない（誰かが Claude に「反映して」と指示する必要がある）
- Claude が直接 Confluence を更新すると、git 上の Markdown と内容がズレるリスクがある
- Confluence 側での直接編集も可能なため、どちらが正本か曖昧になる

## mcp-atlassian が向いているケース

- 「この Confluence ページ、内容を検索して要約して」
- 「新しいページをドラフトで作っておいて」
- 既存の Confluence をそのまま使いつつ AI から操作したい

要するに、**Confluence を AI から触りたい**ニーズには合うが、**git リポジトリを正本にして Confluence に反映する**ニーズには合わない。

## まとめ

自動同期したいなら mark / md2conf / Telefonica sync-action などの CI/CD ツールを使う。MCP サーバーはそれとは別の用途（対話的操作）として補完的に使うもの。ツールの目的を理解してから選定する。
