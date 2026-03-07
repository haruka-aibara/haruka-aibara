<!-- Space: harukaaibarapublic -->
<!-- Parent: Code Review -->
<!-- Title: AI によるコードレビューの自動化 -->

# AI によるコードレビューの自動化

## 問題

PR のレビューは時間がかかる。特に「typo」「命名が微妙」「ここ例外ハンドリング忘れてる」レベルの指摘は、人間がやるより AI にやらせるほうが速い。人間のレビュアーは設計・ロジック・要件への適合といった高次の判断に集中したい。

---

## 主な選択肢

### 1. GitHub Copilot Code Review（一番手軽）

GitHub が提供するネイティブの AI レビュー機能。PR を開くと Copilot がレビューコメントを自動でつける。

**有効化**: リポジトリの Settings → Copilot → Copilot code review を有効にする。または PR 画面の Reviewers から「Copilot」を指定。

**向いている用途**:
- コードの問題点・改善提案をサクッと出したい
- 既存のワークフローを変えたくない

**制限**: GitHub Copilot のサブスクリプションが必要。カスタマイズ性は低い。

---

### 2. Claude Code + GitHub MCP（インタラクティブなレビュー）

Claude Code に GitHub MCP サーバーを組み込んでいれば、PR の diff を取得して Claude に投げることができる。

```
# Claude Code 上で
mcp__github__pull_request_read で PR の diff を取得して、
コードレビューをしてください
```

レビューコメントをそのまま PR に書き込むこともできる。

**向いている用途**:
- 「この PR の設計方針を踏まえてレビューして」など文脈を込みで頼みたい
- レビュー観点を会話しながら調整したい
- コードの意図を説明してから指摘してほしい

**制限**: 自動化ではなく手動トリガー。

---

### 3. GitHub Actions + AI API（完全自動化）

PR が開かれたら自動で AI にレビューさせて、コメントを書き込む。Claude API や OpenAI API を GitHub Actions から叩く。

詳細は [GitHub Actions に AI レビューを組み込む](./GitHub_ActionsにAIレビューを組み込む.md) を参照。

**向いている用途**:
- PR を開いたら自動でレビューが走ってほしい
- チーム全員に適用したい（個人ツールに依存させたくない）

**制限**: API コストがかかる。設定が必要。

---

## どれを選ぶか

| 状況 | 選択肢 |
|------|--------|
| とにかく今すぐ使いたい | GitHub Copilot Code Review |
| 文脈を込めたレビューをしたい | Claude Code + GitHub MCP |
| チームで自動化したい / PR 開いたら自動で走らせたい | GitHub Actions + AI API |
