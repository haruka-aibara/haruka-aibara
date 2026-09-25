---
name: claude-tuning
description: このリポジトリで Claude が読む指示（AGENTS.md・CLAUDE.md・スキル・Slack ボットのモデル設定）を定期的に見直す。「Claude の定期調整して」「プロンプト監査して」「指示ファイルを見直して」「新しいモデルが出たから見直して」といった依頼で使う。監査・反映・PR までを一続きで回す。記事の執筆や、個別のスキルを新しく作る依頼には使わない。
---

# Claude の定期調整

手順と対象ファイルの一覧は `docs/runbooks/claude-tuning.md`。最初に読む。

## 流れ

1. **監査する** — `claude-api` スキルを `prompt-audit` で呼ぶ。範囲の指定がなければランブック §1 の対象全体。ここではファイルを書き換えない
2. **Slack ボットのモデルを確認する** — `modules/bedrock-slack-ai-chatbot/main_bedrock.tf` のモデルが、Bedrock で使える最新世代より古ければ報告に書き、`/claude-api migrate` を提案する。移行はこのスキルの中ではやらない（インフラ変更なので別 PR にする）
3. **結果を見せて止まる** — 監査レポートと diff を出し、どのハンクを反映するか聞く。本人の好みで書いた行（`AGENTS.md` の話し方など）は却下されやすいので、そう添える
4. **反映する** — 選ばれたハンクだけ。`.md` を変えたら `npx --yes markdownlint-cli2 <変更したファイル>` を通す。モジュール配下のコードを変えたら、そのモジュールの `CLAUDE.md` にある CI コマンドを通す
5. **PR を作る** — `.github/PULL_REQUEST_TEMPLATE.md` に従う。タイトルは `Claude 定期調整:` で始める（履歴はこの PR 群で追う）。反映しなかった flag は本文に残す。何も見つからなかった回は PR を作らず、その旨を報告して終える

何も見つからないのは正しい結果。件数を作るために削らない。
