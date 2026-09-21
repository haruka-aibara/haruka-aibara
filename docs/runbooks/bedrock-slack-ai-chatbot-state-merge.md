# bedrock-slack-ai-chatbot state 統合手順書

**目的:** 独立していた `bedrock-slack-ai-chatbot` リポジトリ(と、そのアプリ基盤 AWS インフラを管理する専用 HCP Terraform ワークスペース)を、`works` モノレポと `works` の Terraform state に統合する。

**前提:** git 履歴の統合(`bedrock-slack-ai-chatbot/` 配下への `git filter-repo --to-subdirectory-filter` + `git merge --allow-unrelated-histories`)と、`bedrock-slack-ai-chatbot/*.tf` を `works` ルートから呼ぶ子モジュールへ再構成するコード変更は完了済み(このブランチのコミット参照)。この手順書は Claude が実行できない残りの手作業のみを扱う。

---

## 1. なぜ手作業が残るか

- import 対象の実 AWS リソース ID/ARN(Lambda 関数名、API Gateway API ID、SQS キュー URL、Bedrock 推論プロファイル ARN など)は、旧ワークスペースの state にしかない。作業環境に `TFE_TOKEN` / AWS クレデンシャルが無いため取得できない。
- `works` ワークスペースに新規追加した `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / Slack シークレットの実値は、Terraform コードには書けない(sensitive variable のプレースホルダ `set-in-ui` のみコード管理、実値は HCP Terraform の UI で設定する既存パターン。`workspace_variables.tf` の `GITHUB_APP_*` と同じ)。
- 旧ワークスペースの削除、旧リポジトリの削除は HCP Terraform / GitHub の管理操作であり、Terraform コードの外側の操作。

---

## 2. Phase A: import ブロックの完成

- [ ] **A-1. 旧ワークスペースで state を取得する**

  `bedrock-slack-ai-chatbot` ワークスペースに対して認証済みの環境で:

  ```bash
  terraform state pull > bedrock-slack-ai-chatbot.tfstate.json
  ```

  または HCP Terraform UI の該当ワークスペース → States タブから最新バージョンをダウンロードしてもよい。

- [ ] **A-2. 出力を共有する**

  `bedrock-slack-ai-chatbot.tfstate.json` の内容(または `terraform state list` + 各リソースの `id` 一覧)を Claude に渡す。**このファイルには機微情報は含まれない見込みだが**(Slack トークン等は state の attribute 値であり、resource id/ARN 自体は機微ではない)、念のため共有前に `resources[].instances[].attributes` に見覚えのない値が無いか一読する。

- [ ] **A-3. `imports_2026.tf` を完成させる(Claude 側の作業)**

  共有された ID をもとに、`imports_2025.tf` と同じ書式で `works/imports_2026.tf` に以下の `import` ブロックを追加する(module アドレスは `module.bedrock_slack_ai_chatbot_infra.*`)。

  | リソース | 個数 |
  |---|---|
  | `aws_lambda_function` | 2 |
  | `aws_lambda_layer_version` | 2 |
  | `aws_lambda_event_source_mapping` | 1 |
  | `aws_lambda_permission` | 1 |
  | `aws_iam_role` | 2 |
  | `aws_iam_policy` | 2 |
  | `aws_iam_role_policy_attachment` | 2 |
  | `aws_dynamodb_table` | 1 |
  | `aws_sqs_queue` | 2 |
  | `aws_sqs_queue_redrive_allow_policy` | 1 |
  | `aws_apigatewayv2_api` / `_integration` / `_route` / `_stage` | 4 |
  | `aws_bedrock_inference_profile` | 1 |
  | `aws_cloudwatch_log_group` | 3 |

  合計 24 リソース。旧 state の `terraform state list` と突き合わせて過不足がないことを確認する。

---

## 3. Phase B: 認証情報の設定

- [ ] **B-1. `works` ワークスペースに AWS クレデンシャルを設定する**

  HCP Terraform → `works` ワークスペース → Variables で、コードが宣言済みのプレースホルダに実値を入れる。

  | 変数 | 取得元 |
  |---|---|
  | `AWS_ACCESS_KEY_ID` | 旧ワークスペースの同名変数、または新規発行 |
  | `AWS_SECRET_ACCESS_KEY` | 同上 |
  | `bedrock_slack_ai_chatbot_slack_bot_token` | 旧ワークスペースの `slack_bot_token` |
  | `bedrock_slack_ai_chatbot_slack_signing_secret` | 旧ワークスペースの `slack_signing_secret` |

  `bedrock_slack_ai_chatbot_slack_bot_token` / `_slack_signing_secret` は category を **terraform**(Terraform 変数)にすること。`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` は **env**(環境変数、AWS provider が直接読む)。

---

## 4. Phase C: PR とカットオーバー

- [ ] **C-1. このブランチ(`import-bedrock-slack-ai-chatbot-history`)+ `imports_2026.tf` で PR を作成する**

- [ ] **C-2. speculative plan を確認する**

  期待する結果:

  - `module.bedrock_slack_ai_chatbot_infra.*` の約24リソースが **import**(`will be imported`)
  - `Repository` タグが旧リポジトリ URL → `works` の URL に変わる **1件程度の in-place update**(意図した差分。§ Phase 2 参照)
  - それ以外の **unexpected な変更・destroy が無いこと**

  1件でも import 対象外の diff(re-create, unexpected update)が出た場合は **merge しない**。`works` は `auto_apply = true` のため、merge した瞬間に本番 AWS インフラへ apply される。

- [ ] **C-3. 問題なければ merge して apply を確認する**

  apply 後、Slack でボットに実際にメンションして応答が返ることを確認する(本番動作確認)。

---

## 5. Phase D: 旧環境の廃止(カットオーバー確認後、別 PR)

- [ ] **D-1. 旧ワークスペースの state を空にする、またはワークスペースごと削除する**

  旧 `bedrock-slack-ai-chatbot` ワークスペースの state にも同じリソースが引き続き載っている(import は `works` 側に state エントリを追加するだけで、旧 state からは何も削除しない)。放置すると同じ AWS リソースを2つの state が管理してしまい、どちらかで誤って `apply`/`destroy` が走ると衝突する。

  HCP Terraform UI の該当ワークスペース → Settings → Destruction and Deletion から、**force delete**(state ごと削除。実 AWS リソースは削除しない)を行う。

- [ ] **D-2. `hcp_terraform.tf` から `tfe_workspace.bedrock-slack-ai-chatbot` を外す**

  `removed_2026.tf` の `module.haruka-aibara-private` と同じ形で:

  ```hcl
  removed {
    from = tfe_workspace.bedrock-slack-ai-chatbot

    lifecycle {
      destroy = false
    }
  }
  ```

  (D-1 で実体を既に消しているため `destroy = false` でよい。)`imports_2025.tf` の対応する import ブロックも削除する。

- [ ] **D-3. 旧 GitHub リポジトリを削除する**

  GitHub 上で `haruka-aibara/bedrock-slack-ai-chatbot` を削除する。

- [ ] **D-4. `main.tf` から `module "bedrock-slack-ai-chatbot"`(github_repository)を外す**

  `modules/repository` の `github_repository.this` は `lifecycle { prevent_destroy = true }` なので、`removed` ブロックだけでは destroy が prevent_destroy に阻まれる可能性がある。D-3 で実体を先に消していれば `destroy = false` の `removed` ブロックで外すだけでよい(既に存在しないリソースの destroy は発生しない)。

---

## 6. ロールバック

| 発生箇所 | 復旧方法 |
|---|---|
| Phase C の speculative plan で unexpected な diff が出た | merge しない。`imports_2026.tf` か再構成コードを見直す |
| apply 後に不具合が発覚した | HCP Terraform の works ワークスペース States タブから直前バージョンに rollback。旧ワークスペースの state・旧リポジトリを Phase D で消していなければ、最悪そちらに戻すことも可能 |
| Phase D で旧ワークスペースを先に消してしまった | Phase C の apply が成功していれば実 AWS リソースは `works` 側で管理され続けているため実害はない |
