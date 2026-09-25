# Jira → PR 自動化

Jira の `SCRUM` プロジェクトで課題を「AI 実装」スプリントに入れると、Claude Code が実装し、別の Claude がレビューして draft PR を作り、PR の CI が終わったら Slack の `#haru` に知らせる。設計の判断は [ADR-0003](../decisions/0003-jira-to-pr.md)。

## 流れ

```text
Jira（SCRUM-12 を「AI 実装」スプリントへ）
  → Jira Automation が workflow_dispatch を送る
  → .github/workflows/jira-to-pr.yml
      implement: Claude Code（Bedrock, OIDC）が実装・検査し、差分をパッチにする
      review:    まっさらな環境で、別の Claude が読み取り専用でレビューする
      publish:   まっさらな環境にパッチを当て、GitHub App のトークンで
                 ai/SCRUM-12 を push し draft PR を作り、PR の CI が終わるまで待つ
  → Slack #haru に通知（CI の結果とレビューの判定つき）
```

Jira キーを branch（`ai/SCRUM-12`）と PR タイトル（`[SCRUM-12] …`）に入れるので、Jira の GitHub 連携（GitHub for Jira）を入れていれば課題に PR が自動でぶら下がる。

## 登場人物と置き場所

| もの | 置き場所 | 管理 |
|---|---|---|
| AWS の OIDC プロバイダと IAM ロール `jira-to-pr-github-actions` | `modules/jira-to-pr/` | Terraform |
| GitHub environment `jira-to-pr`（main からのみ実行可） | `modules/jira-to-pr/` | Terraform |
| environment の変数 `AWS_ROLE_ARN` / `APP_CLIENT_ID` / `SLACK_CHANNEL_ID` | GitHub UI | 手作業 |
| environment の secret `APP_PRIVATE_KEY` / `SLACK_BOT_TOKEN` | GitHub UI | 手作業 |
| PR 作成用の GitHub App | GitHub UI | 手作業 |
| 起動用の fine-grained PAT | Jira Automation のルール内 | 手作業 |
| Jira Automation のルール | Jira UI | 手作業 |

## 初期設定

main へのマージで Terraform が AWS ロールと environment を作る。その後に以下を手でやる。

### 1. PR 作成用の GitHub App を作る

Terraform 用の App は org の管理権限を持つので流用しない。専用に作る。

- Repository permissions: **Contents: Read and write**、**Pull requests: Read and write**、**Checks: Read-only**、**Commit statuses: Read-only**（Metadata は自動で Read）。Checks と Commit statuses は PR の CI を待つのに使う。**Workflows は付けない**。付けなければ、エージェントが `.github/workflows/` を書き換えても push が拒否される
- Webhook は無効
- org `haruka-aibara` の `works` にだけインストールする
- Client ID と秘密鍵（PEM）を控える

`GITHUB_TOKEN` で作った PR には CI が走らない（GitHub の仕様）ので、PR 作成には App が要る。

### 2. environment に値を入れる

Settings → Environments → `jira-to-pr`：

| 種類 | 名前 | 値 |
|---|---|---|
| Variable | `AWS_ROLE_ARN` | `terraform output` の `module.jira_to_pr.role_arn`（`arn:aws:iam::<account>:role/jira-to-pr-github-actions`） |
| Variable | `APP_CLIENT_ID` | 手順 1 の Client ID |
| Variable | `SLACK_CHANNEL_ID` | `#haru` のチャンネル ID（チャンネル名を右クリック → リンクをコピー の末尾 `C…`） |
| Secret | `APP_PRIVATE_KEY` | 手順 1 の PEM |
| Secret | `SLACK_BOT_TOKEN` | chatbot と同じ Bot User OAuth Token |

### 3. Slack のボットを `#haru` に招待する

`#haru` は private channel なので、ボットがメンバーでないと `chat.postMessage` が `channel_not_found` で失敗する。チャンネルで `/invite @<ボット名>` する。スコープは既存の `chat:write` で足りる。

### 4. 起動用の PAT を作る

GitHub の fine-grained PAT。

- Repository access: `haruka-aibara/works` のみ
- Permissions: **Actions: Read and write** だけ（workflow_dispatch に必要な最小）。Contents は付けない。漏れてもワークフローを起動できるだけで、コードは書けない
- 有効期限は 90 日。期限切れで Automation が 401 になったら作り直す

### 5. Jira Automation のルールを作る

入口は「AI 実装」という名前のスプリントにする。ステータスの追加はワークフローの変更で、大きな組織では Jira 管理者への申請が要ることが多い。スプリントはプロジェクトの中で作れるので、手続きなしで済む。

まず入れ物のスプリントを作る。

- バックログで「スプリントを作成」し、名前を `AI実装（開始しない）` にする
- **開始しない**。未開始のスプリントはバーンダウンやベロシティに入らず、完了操作で課題が別のスプリントへ移ることもない
- スプリント ID を控える（スプリント名のメニュー → 編集の URL や、課題の「スプリント」欄のリンクに出る数字）。名前は変えられるうえ重複もしうるので、判定には ID を使う

次にルールを作る。プロジェクト `SCRUM` → 自動化 → ルールを作成：

- **トリガー**: フィールド値の変更時 → フィールド「スプリント」
- **条件**: 課題が条件に一致 → JQL `sprint = <控えたスプリント ID>`。スプリントから外したときには動かない
- **条件**（推奨）: 実行者が自分であること。第三者が起票したチケットをそのまま流さない
- **アクション**: Web リクエストを送信
  - URL: `https://api.github.com/repos/haruka-aibara/works/actions/workflows/jira-to-pr.yml/dispatches`
  - メソッド: POST
  - ヘッダー: `Authorization: Bearer <手順 4 の PAT>`、`Accept: application/vnd.github+json`、`X-GitHub-Api-Version: 2022-11-28`
  - Web リクエストの本文: カスタムデータ

```json
{
  "ref": "main",
  "inputs": {
    "issue_key": "{{issue.key}}",
    "summary": "{{issue.summary.jsonEncode}}",
    "description": "{{issue.description.jsonEncode}}",
    "issue_url": "{{issue.url}}"
  }
}
```

`jsonEncode` は引用符・改行を JSON 用にエスケープする。説明が空でも `""` になるので本文が壊れない。成功すると 204 が返る。

### 6. GitHub から手動で試す

Jira を通さずにワークフローを直接起動して動作確認できる。初期設定の検証や障害の切り分けに使う。

Actions → Jira to PR → **Run workflow** を開き、以下を入力する。

| 入力 | 値 |
|---|---|
| `issue_key` | `SCRUM-<番号>`（既存の課題でも、テスト用に作った課題でもよい） |
| `summary` | 課題のタイトル |
| `description` | 課題の説明文（空でもよい） |
| `issue_url` | `https://<site>.atlassian.net/browse/SCRUM-<番号>`。この形式でないと Validate issue で止まる |

成功すると `ai/SCRUM-<番号>` ブランチに draft PR ができ、`#haru` に通知が届く。確認が済んだら PR を Close してブランチを削除する。

publish だけが失敗した場合は、ワークフローの実行画面で **Re-run failed jobs** を使えば Claude の実装・レビューを再実行せずに publish からやり直せる。

## チケットの書き方

エージェントはチケットの説明文しか読まない。[AI エージェント時代のチケット管理](../Scrum/AIエージェント時代のチケット管理.md) の 4 点を書く。

- 実行するコマンド（検査はワークフローのプロンプトにも書いてあるので、特別なものだけ）
- 触る場所
- やること / やらないこと
- 受け入れ条件（検証できる形で）

## 止め方

- 一時停止: Jira Automation のルールを無効にする。または GitHub の Actions でワークフロー `Jira to PR` を Disable する
- 完全停止: environment の `APP_PRIVATE_KEY` を消す。PR は作れなくなる（Claude の実装とレビューまでは走る）
- 起動用 PAT が漏れた疑い: PAT を revoke する。できるのはワークフローの起動だけだが、Bedrock の料金はかかる

## うまくいかないとき

| 症状 | 見るところ |
|---|---|
| Automation の監査ログで 401 / 403 | PAT の期限・権限（Actions: write）・対象リポジトリ |
| 422 `Unexpected inputs` | 本文の `inputs` のキー名がワークフローの inputs と一致しているか |
| `Validate issue` で失敗 | キーが `SCRUM-数字`、URL が `https://<site>.atlassian.net/browse/SCRUM-数字` か |
| AWS の認証で `Not authorized to perform sts:AssumeRoleWithWebIdentity` | 東京リージョンの CloudTrail で失敗した `AssumeRoleWithWebIdentity` の `userName`（トークンの sub）を見る。この org の sub は `repo:haruka-aibara@<org id>/works@<repo id>:environment:jira-to-pr` の形で、ロールの信頼条件と一致している必要がある。ジョブが environment `jira-to-pr` で走っているか（main 以外からは走れない）も確認 |
| Bedrock で `AccessDeniedException` | モデルアクセスの有効化、IAM の対象モデル（`modules/jira-to-pr` の `bedrock_model_id`） |
| `Apply patch` で `the change touches .github/` | エージェントが `.github/` を変えている。意図どおりの拒否 |
| `Wait for CI` が失敗する / Slack が「CI red」なのに PR の CI は緑 | App に Checks / Commit statuses の Read が付いているか |
| Slack に来ない | ボットが `#haru` にいるか、`SLACK_CHANNEL_ID` が ID（名前ではない）か |
