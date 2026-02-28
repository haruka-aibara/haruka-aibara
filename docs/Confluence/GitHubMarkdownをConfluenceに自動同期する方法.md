<!-- Space: harukaaibarapublic -->
<!-- Title: GitHub Markdown を Confluence に自動同期する方法 -->

# GitHub Markdown を Confluence に自動同期する方法

2026年2月時点の調査まとめ。Cloud / DC 両対応を見据えた選定基準で整理している。

---

## ツール比較

| ツール | Cloud | DC | GH Actions | 変換形式 | メンテ状況 |
|---|---|---|---|---|---|
| **mark** (kovetskiy) | ○ | ○ | ○ (Docker) | HTML | 活発（v15.3.0） |
| markdown-confluence | ○ | × | ○ | ADF | やや停滞（最終 2024年9月） |
| md2conf (hunyadi) | ○ | △ | △ | XHTML | 活発（API v2 対応済） |
| Telefonica sync-action | ○ | 不明 | ◎ (専用設計) | HTML+SVG | 活発（2025年11月実績あり） |
| Atlassian Rovo MCP | ○ | × | × | AI依存 | 公式 GA (2025年末) |
| Marketplace embed アプリ | ○ | × | × | ネイティブ | 商用サポート |

> **注意**: Atlassian は 2025年3月31日に Confluence Cloud の REST API v1 の一部エンドポイントを廃止。古いバージョンのツールを使う場合は API v2 対応を確認すること。

---

## 各ツールの概要

### mark（最有力候補）

- リポジトリ: https://github.com/kovetskiy/mark
- Cloud / Server / DC すべてに対応しており、Cloud と DC を両方使いたい場合に最適

各 Markdown ファイルの先頭に Confluence 固有のコメントヘッダーを書く方式:

```markdown
<!-- Space: MYSPACE -->
<!-- Parent: Engineering -->
<!-- Title: My Document -->

# 本文...
```

GitHub Actions での使用例:

```yaml
- name: Push to Confluence
  uses: docker://ghcr.io/kovetskiy/mark:latest
  env:
    MARK_USERNAME: ${{ secrets.CONFLUENCE_USER }}
    MARK_PASSWORD: ${{ secrets.CONFLUENCE_API_TOKEN }}
    MARK_BASE_URL: https://your-org.atlassian.net/wiki
  with:
    args: -files "docs/**/*.md"
```

DC の場合は `MARK_BASE_URL` を DC インスタンスの URL に変えるだけ。認証方式の違いは以下:

```yaml
# Cloud
MARK_USERNAME: user@example.com
MARK_PASSWORD: <Atlassian API Token>

# DC
MARK_USERNAME: username
MARK_PASSWORD: <Personal Access Token>
MARK_BASE_URL: https://your-dc-instance.example.com/wiki
```

---

### markdown-confluence

- リポジトリ: https://github.com/markdown-confluence/markdown-confluence
- ADF（Atlassian Document Format）ネイティブ変換のため Cloud でのレンダリング品質は高い
- Cloud 専用。DC 不可
- 最終リリースが 2024年9月でやや停滞気味
- このリポジトリでも試みたが `markdown-confluence/publish-action` は 2023年から更新なく、Node.js の Deprecation 警告・Chrome ダウンロード失敗等のエラーが発生（→ `GitHubリポジトリとConfluence同期.md` 参照）

---

### md2conf（hunyadi/md2conf）

- リポジトリ: https://github.com/hunyadi/md2conf
- PyPI パッケージ名: `markdown-to-confluence`
- Python 製。2025年3月の API v1 廃止に対応し REST API v2 へ移行済み
- ディレクトリ構造 → ページ階層の自動マッピングに対応

```bash
pip install markdown-to-confluence
python3 -m md2conf sync ./docs --space MYSPACE --root-page "Engineering Docs"
```

---

### Telefonica/markdown-confluence-sync-action

- リポジトリ: https://github.com/Telefonica/markdown-confluence-sync-action
- GitHub Actions 専用設計。ディレクトリ構造をページ階層にミラーリングする Tree モードが特徴
- Mermaid → SVG、Draw.io → PNG の自動変換・画像添付に対応
- スター数が少なく（Telefónica 社内ツール発）、長期メンテナンスに不確実性あり

```yaml
- name: Sync docs to Confluence
  uses: Telefonica/markdown-confluence-sync-action@v2
  with:
    confluence-url: https://your-org.atlassian.net/wiki
    confluence-space-key: MYSPACE
    confluence-parent-page-id: "123456"
    sync-mode: tree
    docs-dir: ./docs
  env:
    CONFLUENCE_TOKEN: ${{ secrets.CONFLUENCE_API_TOKEN }}
```

---

### Atlassian Rovo MCP Server

- 公式ページ: https://www.atlassian.com/platform/remote-mcp-server
- 2025年末に GA（Generally Available）に昇格した公式 MCP サーバー
- Claude Code や Cursor 等の AI クライアントから Confluence ページを直接生成・更新できる
- バッチ自動同期には不向き。「書いたらすぐ発行」という人間主導のワークフロー向け
- Rovo ライセンスが必要（無料プランでは利用不可の可能性あり）

---

### Marketplace embed 型アプリ（有料）

GitHub の URL を Confluence ページに貼るだけで自動レンダリング・同期される方式。
コンテンツは GitHub が Single Source of Truth のまま保たれるため、Confluence 側で編集してしまう事故が起きない。

| アプリ名 | リンク |
|---|---|
| Include from GitHub to Confluence | https://marketplace.atlassian.com/apps/1228981 |
| Git for Confluence | https://marketplace.atlassian.com/apps/1211675 |

---

## mark のセキュリティ・企業利用観点

### ライセンス

**Apache License 2.0** — 商用・エンタープライズ利用は完全に許可。

### 認証情報の扱い

- `--log-level DEBUG` までは `password: ******` でマスクされる
- `--log-level TRACE` では HTTP ヘッダーが出力される可能性があるため本番では使わない
- `~/.config/mark.toml` に書くと平文保存になる → CI/CD では環境変数（`MARK_PASSWORD`）で渡す

### 第三者へのデータ送信

指定した Confluence インスタンスのみに通信する。外部サービスへのデータ送信はなし。

### Docker イメージの注意点

- Mermaid レンダリングのため Chromium を含む構成（`chromedp/headless-shell` ベース）で攻撃面が大きい
- タグが `latest` 固定のため、本番利用ではダイジェスト指定（`@sha256:...`）で固定することを推奨
- 自社の Trivy / Grype 等でスキャンしてから使う

### 必要な Confluence 権限（最小権限）

`--edit-lock` を使わない場合、以下の権限のみで動作する:

- Space: Read
- Space: Create Pages
- ページの編集・添付権限

Confluence Cloud では Scoped API Token を使って特定 Space への権限に絞ることが可能。

### エンタープライズ採用状況

公式ケーススタディはないが、スター 1,400+・フォーク 200+・コントリビューター 44 名。
Indeed 関連と思われるコントリビューターも確認されており、複数組織での利用実績がある。

**注意点**: メンテナー（Egor Kovetskiy 氏）本人が「スポンサーなし、バグ修正の優先度は低い」と公言している。商用サポートは期待できないコミュニティ OSS。

---

## ユースケース別おすすめ

| ユースケース | おすすめ |
|---|---|
| GitHub Actions で自動同期したい・Cloud と DC 両方使いたい | **mark** |
| ディレクトリ階層をそのままページ階層に反映したい | **Telefonica sync-action** または mark |
| ファイルは GitHub が正本のまま、Confluence には表示だけしたい | **Marketplace embed アプリ** |
| AI（Claude Code 等）からアドホックに発行・更新したい | **Atlassian Rovo MCP Server** |
| Python チームで運用したい | **md2conf** |

---

## 参考リンク

- [kovetskiy/mark - GitHub](https://github.com/kovetskiy/mark)
- [markdown-confluence/markdown-confluence - GitHub](https://github.com/markdown-confluence/markdown-confluence)
- [hunyadi/md2conf - GitHub](https://github.com/hunyadi/md2conf)
- [Telefonica/markdown-confluence-sync-action - GitHub](https://github.com/Telefonica/markdown-confluence-sync-action)
- [Atlassian Rovo MCP Server - 公式ページ](https://www.atlassian.com/platform/remote-mcp-server)
- [Include from GitHub to Confluence - Atlassian Marketplace](https://marketplace.atlassian.com/apps/1228981)
- [Git for Confluence - Atlassian Marketplace](https://marketplace.atlassian.com/apps/1211675)
- [Publishing Markdown to Confluence using GitHub Actions - DEV Community](https://dev.to/vearutop/publishing-markdown-to-confluence-using-github-actions-1k4g)
- [Automate Publishing Markdown Files from GitHub to Confluence - DEV Community](https://dev.to/andygolubev/automate-publishing-markdown-files-from-github-to-confluence-with-github-to-confluence-publisher-tool-eh4)
- [Markdown to Confluence Sync Workflow - paval.io](https://paval.io/posts/2025-11-29-markdown-to-confluence-sync/)
