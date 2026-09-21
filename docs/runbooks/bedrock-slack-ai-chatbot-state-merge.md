# bedrock-slack-ai-chatbot state 統合手順書

**ステータス: 完了。** Phase A〜D すべて完了し、旧リポジトリ・旧ワークスペースとも実際に削除済み(2026-09-21)。未完了なのは C-2a(`ignore_changes` を外すフォローアップ)のみ。

**目的:** 独立していた `bedrock-slack-ai-chatbot` リポジトリ(と、そのアプリ基盤 AWS インフラを管理する専用 HCP Terraform ワークスペース)を、`works` モノレポと `works` の Terraform state に統合する。

**前提:** git 履歴の統合(`bedrock-slack-ai-chatbot/` 配下への `git filter-repo --to-subdirectory-filter` + `git merge --allow-unrelated-histories`)と、`bedrock-slack-ai-chatbot/*.tf` を `works` ルートから呼ぶ子モジュールへ再構成するコード変更は完了済み(このブランチのコミット参照)。この手順書は Claude が実行できない残りの手作業のみを扱う。

---

## 1. なぜ手作業が残るか

- import 対象の実 AWS リソース ID/ARN(Lambda 関数名、API Gateway API ID、SQS キュー URL、Bedrock 推論プロファイル ARN など)は、旧ワークスペースの state にしかない。作業環境に `TFE_TOKEN` / AWS クレデンシャルが無いため取得できない。
- `works` ワークスペースに新規追加した Slack シークレットの実値は、Terraform コードには書けない(sensitive variable のプレースホルダ `set-in-ui` のみコード管理、実値は HCP Terraform の UI で設定する既存パターン。`workspace_variables.tf` の `GITHUB_APP_*` と同じ)。AWS 自体は静的キーではなく dynamic provider credentials(OIDC)を使う方針に変更したため、AWS 側の認証情報は `TFC_AWS_PROVIDER_AUTH` / `TFC_AWS_RUN_ROLE_ARN` を UI で設定するのみで、Terraform コード側に対応する secret は無い(§3 参照)。
- 旧ワークスペースの削除、旧リポジトリの削除は HCP Terraform / GitHub の管理操作であり、Terraform コードの外側の操作。

---

## 2. Phase A: import ブロックの完成

- [x] **A-1. 旧ワークスペースで state を取得する**

  `bedrock-slack-ai-chatbot` ワークスペースに対して認証済みの環境で:

  ```bash
  terraform state pull > bedrock-slack-ai-chatbot.tfstate.json
  ```

  または HCP Terraform UI の該当ワークスペース → States タブから最新バージョンをダウンロードしてもよい。

- [x] **A-2. 出力を共有する**

  `bedrock-slack-ai-chatbot.tfstate.json` の内容(または `terraform state list` + 各リソースの `id` 一覧)を Claude に渡す。**このファイルには機微情報は含まれない見込みだが**(Slack トークン等は state の attribute 値であり、resource id/ARN 自体は機微ではない)、念のため共有前に `resources[].instances[].attributes` に見覚えのない値が無いか一読する。

- [x] **A-3. `imports_2026.tf` を完成させる(Claude 側の作業)**

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

- [x] **B-1. `works` ワークスペースに AWS の dynamic provider credentials (OIDC) を設定する**

  静的キー(`AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`)は使わない方針にしたため、Terraform コード側に対応する `tfe_variable` は無い。HCP Terraform → `works` ワークスペース → Variables で、以下を **env** カテゴリで直接追加する(UI管理のみ、Terraform ではimportも作成もしない)。

  | 変数 | 値 |
  |---|---|
  | `TFC_AWS_PROVIDER_AUTH` | `true` |
  | `TFC_AWS_RUN_ROLE_ARN` | HCP Terraform を信頼する IAM role の ARN(AWS 側に IAM OIDC provider + role が事前に用意されている前提) |

- [x] **B-2. `works` ワークスペースに Slack シークレットを設定する**

  HCP Terraform → `works` ワークスペース → Variables で、コードが宣言済みのプレースホルダに実値を入れる。category は **terraform**(Terraform 変数)。

  | 変数 | 取得元 |
  |---|---|
  | `bedrock_slack_ai_chatbot_slack_bot_token` | 旧ワークスペースの `slack_bot_token` |
  | `bedrock_slack_ai_chatbot_slack_signing_secret` | 旧ワークスペースの `slack_signing_secret` |

  先に UI で手動作成すると、`tfe_variable` リソースの新規作成が `Key has already been taken` で失敗する。その場合は `import` ブロックで既存を取り込む(`imports_2026.tf` 参照、実績あり)。

---

## 4. Phase C: PR とカットオーバー

- [x] **C-1. このブランチ(`import-bedrock-slack-ai-chatbot-history`)+ `imports_2026.tf` で PR を作成する**

- [x] **C-2. speculative plan を確認する**

  期待する結果(1回目の手動planで確認済みの実績あり。詳細は下記「つまずいた点」参照):

  - `module.bedrock_slack_ai_chatbot_infra.*` の24リソースが **import**(`will be imported`)
  - `Repository` タグが旧リポジトリ URL → `works` の URL に変わる **in-place update**(意図した差分。各リソースの `tags`/`tags_all` に出る)
  - `tfe_variable.*` 4件の **create**(Phase B のプレースホルダ)
  - `github_repository_file.*_caller["bedrock-slack-ai-chatbot"]` 2件の **destroy**(旧リポジトリから CI ファイルを削除。意図した差分)
  - `github_repository_file.python_ci_caller["works"]` の **create**、`reusable_python_ci` の **update**(CI配布の付け替え)
  - 2つの Lambda 関数の **in-place update**(`filename`/`source_code_hash`/`publish` が追加されるだけで、中身は同一コードの再デプロイ。危険ではない)
  - それ以外の **unexpected な変更・destroy(特に `must be replaced` / `-/+`)が無いこと**。とくに `aws_bedrock_inference_profile` と `aws_lambda_layer_version` ×2 は要注意(下記参照)。

  1件でも上記に当てはまらない diff が出た場合は **merge しない**。`works` は `auto_apply = true` のため、merge した瞬間に本番 AWS インフラへ apply される。

  **つまずいた点(1回目のplanで発生・修正済み)**: `model_source`(inference profile)と `filename`/`skip_destroy`(layer version)は AWS 側から読み返せない作成時専用の属性で、import直後は state 上 null になる。コード側の値と比較すると「新規追加」に見えて `-/+` (destroy & recreate) が誘発された。本番で使用中のリソースなので、`lifecycle { ignore_changes = [...] }` で該当属性を一時的に無視する修正を入れている。

- [ ] **C-2a. (フォローアップ、別PR) `ignore_changes` を外す**

  import が安定してから、`main_bedrock.tf` の `aws_bedrock_inference_profile.claude_opus_4_6` と `main_lambda.tf` の `aws_lambda_layer_version` ×2 に付けた `lifecycle { ignore_changes = [...] }` を削除する PR を出す。外さないままだと、将来モデルや Lambda layer のコードを本当に変更しても apply に反映されない。

- [x] **C-3. 問題なければ merge して apply を確認する**

  apply 後、Slack でボットに実際にメンションして応答が返ることを確認する(本番動作確認)。

---

## 5. Phase D: 旧環境の廃止(カットオーバー確認後、別 PR)

旧ワークスペース・旧リポジトリのどちらも、**手動で先に消すのではなく Terraform に実 destroy させる**(このリポジトリの存在意義そのものがライフサイクルをコードで管理することなので、手動削除は最後の手段)。ただしどちらも安全装置(safe delete / `prevent_destroy`)があるため、2段階のPRに分ける。

### D-1. 旧ワークスペース: force_delete を先に効かせる(PR その1)

`hcp_terraform.tf` の `tfe_workspace.bedrock-slack-ai-chatbot` に `force_delete = true` を追加して apply する(ブロック自体はまだ消さない)。

```hcl
resource "tfe_workspace" "bedrock-slack-ai-chatbot" {
  # ...既存の引数はそのまま...
  force_delete = true
}
```

`force_delete` は「破棄時に、このワークスペースの state に他の Terraform 管理リソースが残っていても強制的に削除する(実リソースは削除しない)」という意味の通常の resource 引数であり、`prevent_destroy` のような lifecycle メタ引数ではない。**state に値が載って初めて意味を持つ**ため、このブロックをまだ削除してはいけない(削除と同じ apply でやると、まだ `force_delete=true` が state に反映されておらず通常の safe delete のまま失敗する)。

- [x] このPRを apply する
- [x] apply 成功後、旧ワークスペースの Variables ページ等で `force_delete` が効いていることを確認してよい(任意)

### D-2. 旧ワークスペース: ブロックを削除して実 destroy させる(PR その2、D-1 の apply 成功後)

`hcp_terraform.tf` から `tfe_workspace.bedrock-slack-ai-chatbot` のブロックを丸ごと削除する。`removed` ブロックではなく、素直に消して destroy させる(D-1 で state に `force_delete=true` が乗っているので、safe delete ではなく force delete の API が呼ばれ、旧ワークスペースの state だけが破棄される。実 AWS リソースは無関係)。

- [x] このPRの speculative plan で `tfe_workspace.bedrock-slack-ai-chatbot` が **destroy** になっていることを確認
- [x] `imports_2025.tf` の対応する import ブロックが残っていれば削除する(既に state にあるので実害はないが、掃除する)

### D-3. 旧 GitHub リポジトリ: prevent_destroy を外して実 destroy させる

`main.tf` から `module "bedrock-slack-ai-chatbot"`(github_repository)を削除し、同じPRで `modules/repository/main.tf` の `lifecycle { prevent_destroy = true }` を **一時的に** `false` にする。

外さないと `github_repository.this` が「削除しようとしたが prevent_destroy に阻まれた」というエラーで apply が失敗する(このモジュールは全リポジトリ共通なので、この間は全リポジトリの削除保護が外れる点に注意)。

- [x] speculative plan で `bedrock-slack-ai-chatbot` の `github_repository` / `github_repository_vulnerability_alerts` / `github_branch_protection` が **destroy**、それ以外の既存リポジトリに diff が出ていないことを確認
- [x] apply 成功を確認したら **速やかに** `prevent_destroy = true` へ戻す別PRを出す(保護が外れた状態を長く放置しない)

---

## 6. ロールバック

| 発生箇所 | 復旧方法 |
|---|---|
| Phase C の speculative plan で unexpected な diff が出た | merge しない。`imports_2026.tf` か再構成コードを見直す |
| apply 後に不具合が発覚した | HCP Terraform の works ワークスペース States タブから直前バージョンに rollback。旧ワークスペースの state・旧リポジトリを Phase D で消していなければ、最悪そちらに戻すことも可能 |
| Phase D で旧ワークスペースを先に消してしまった | Phase C の apply が成功していれば実 AWS リソースは `works` 側で管理され続けているため実害はない |
