# Claude の定期調整

**この文書を読むとき:** 新しい Claude モデルが出たとき。Claude Code の振る舞いや Slack ボットの答えに違和感があるとき。特に何もなくても月1くらいで見直すとき。

**要点:**

- 定期の見直しは `/claude-tuning` で監査 → 反映 → PR まで回る（下の §2 を一続きにしたスキル）。過去の回は PR タイトル `Claude 定期調整:` で検索する
- 指示ファイル・スキルは古いモデル向けの書き方が溜まる。`/claude-api prompt-audit` で洗い出す
- Slack ボット（`modules/bedrock-slack-ai-chatbot`）はモデル ID が固定。新モデルが出たら `/claude-api migrate`
- 許可プロンプトが多いと感じたら `/fewer-permission-prompts`

---

## 1. 対象

| 対象 | 場所 | 誰が読むか |
|---|---|---|
| リポジトリ全体の指示 | `AGENTS.md`（`CLAUDE.md` から読み込み） | Claude Code |
| モジュール別の指示 | `modules/*/CLAUDE.md` | Claude Code |
| スキル | `.claude/skills/*/SKILL.md` と `references/` | Claude Code |
| Claude Code の設定 | `.claude/settings.json` | Claude Code |
| Slack ボットのモデル | `modules/bedrock-slack-ai-chatbot/main_bedrock.tf` の inference profile、`main_iam.tf` の ARN | Bedrock |
| Slack ボットのリクエスト | `lambda_function_bedrock_backend/lambda_function.py`（`generate_answer`）、`var.bedrock_max_tokens` | Bedrock |

## 2. 定期的にやること

| いつ | コマンド | 何が起きるか |
|---|---|---|
| 月1・新モデルが出たとき | `/claude-api prompt-audit` | 上の対象を棚卸しして、古い指示の一覧（`file:line`・理由・確信度）と修正 diff を出す。ファイルは書き換えない |
| 範囲を絞りたいとき | `/claude-api prompt-audit .claude/skills/` | 指定したパスだけ監査する |
| 監査結果を反映するとき | 「全部適用して PR 作って」／「1と3だけ適用して」 | diff のハンクを選んで反映する |
| 新モデルが出て Slack ボットを上げたいとき | `/claude-api migrate` | 移行先モデルと範囲を聞かれるので答える。モデル ID・IAM ARN・破壊的変更（thinking・パラメータ）を直し、最後に prompt-audit も通す |
| Slack ボットの費用が気になるとき | `/claude-api cost-optimize` | usage ログから見積もって、効く順に打ち手を出す |
| 許可プロンプトが多いとき | `/fewer-permission-prompts` | 過去のセッションから読み取り系コマンドを拾い、`.claude/settings.json` の allowlist 案を出す |
| スキルが呼ばれない・呼ばれすぎるとき | skill-creator スキル（「article-writing スキルの description を見直して」） | description の発火条件を評価・調整する |

## 3. 監査結果の読み方

- **High / Medium** は diff に入る。**Low / flag** はレポートだけ（反映しない）
- 残すべきものは消されない。背景・理由・危険な操作の手順・ツールの仕様などは keep list に入っている
- 「何も見つからない」も正しい結果。無理に削らない
- 本人の好みで書いた行（例：`AGENTS.md` の話し方）が指摘されたら、却下してよい

## 4. 自動で回したいとき

Claude Code on the web なら Routine（定期実行）にできる。セッションで「毎月1日に prompt-audit を回してレポートだけ出すようにして」と頼む。反映は結果を見てから手で頼む。
