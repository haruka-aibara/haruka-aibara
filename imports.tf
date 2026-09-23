# 取り込み済みのものも含め、import ブロックはこのファイルにまとめる。
# apply 後の import は no-op だが、どの資源をどの ID で取り込んだかの記録として残す。
# moved / removed ブロックは記録として残さない。apply 済みになったら消す。

# =========================================
# 2025 GitHub Repositories Imports
# =========================================

import {
  to = module.generate-dev-io-summary.github_repository.this
  id = "generate-dev-io-summary"
}

import {
  to = module.deploy-hcp-vault-dedicated-with-terraform.github_repository.this
  id = "deploy-hcp-vault-dedicated-with-terraform"
}

import {
  to = module.aws-custom-lambda-config-rules.github_repository.this
  id = "aws-custom-lambda-config-rules"
}

import {
  to = module.terraform-aws-budget-slack-notifier.github_repository.this
  id = "terraform-aws-budget-slack-notifier"
}

import {
  to = module.aws-cost-allocation-tags.github_repository.this
  id = "aws-cost-allocation-tags"
}

import {
  to = module.iam-access-analyzer-policy-generate.github_repository.this
  id = "iam-access-analyzer-policy-generate"
}

import {
  to = module.bedrock-slack-ai-agent.github_repository.this
  id = "bedrock-slack-ai-agent"
}

import {
  to = module.docker-simple-cicd-demo.github_repository.this
  id = "docker-simple-cicd-demo"
}

import {
  to = module.github-actions-test.github_repository.this
  id = "github-actions-test"
}

import {
  to = module.github-actions-test-react-demo.github_repository.this
  id = "github-actions-test-react-demo"
}

import {
  to = module.github-actions-test-lint-test-deploy-build.github_repository.this
  id = "github-actions-test-lint-test-deploy-build"
}

import {
  to = module.devcontainer-templates.github_repository.this
  id = "devcontainer-templates"
}

import {
  to = module.github-actions-test-events-deep-dive.github_repository.this
  id = "github-actions-test-events-deep-dive"
}

import {
  to = module.github-actions-test-jobs-artifacts-outputs.github_repository.this
  id = "github-actions-test-jobs-artifacts-outputs"
}

import {
  to = module.haruka-aibara.github_repository.this
  id = "works"
}

# =========================================
# 2025 HCP Terraform Workspaces Imports
# =========================================

import {
  to = tfe_workspace.aws-cost-allocation-tags
  id = "haruka-aibara/aws-cost-allocation-tags"
}

import {
  to = tfe_workspace.bedrock-slack-ai-agent
  id = "haruka-aibara/bedrock-slack-ai-agent"
}

import {
  to = tfe_workspace.deploy-hcp-vault-dedicated-with-terraform
  id = "haruka-aibara/deploy-hcp-vault-dedicated-with-terraform"
}

import {
  to = tfe_workspace.generate-dev-io-summary
  id = "haruka-aibara/generate-dev-io-summary"
}

import {
  to = tfe_workspace.works
  id = "haruka-aibara/works"
}

import {
  to = tfe_workspace.iam-access-analyzer-policy-generate
  id = "haruka-aibara/iam-access-analyzer-policy-generate"
}

import {
  to = tfe_workspace.terraform-aws-budget-slack-notifier
  id = "haruka-aibara/terraform-aws-budget-slack-notifier"
}

# =========================================
# 2026 bedrock-slack-ai-chatbot state 統合
# =========================================
# 旧 bedrock-slack-ai-chatbot ワークスペースの state pull 結果(2026-09-21 取得)から
# 実リソース ID を採った import。手順は
# docs/runbooks/bedrock-slack-ai-chatbot-state-merge.md 参照。

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_function.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_function.slack_bolt_app_bedrock_backend
  id = "bedrock-slack-ai-chatbot_bedrock-backend"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_layer_version.slack_ai_chatbot
  id = "arn:aws:lambda:ap-northeast-1:172580074565:layer:bedrock-slack-ai-chatbot:6"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_layer_version.bedrock
  id = "arn:aws:lambda:ap-northeast-1:172580074565:layer:bedrock-slack-ai-chatbot_bedrock-backend:2"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_event_source_mapping.bedrock
  id = "08b1998b-be2e-4e4d-873b-a679b471a16b"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_permission.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot/AllowExecutionFromAPIGateway"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot_role"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role.bedrock_backend
  id = "bedrock-slack-ai-chatbot_bedrock-backend-role"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_policy.slack_ai_chatbot
  id = "arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_policy.bedrock_backend
  id = "arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_bedrock-backend-policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role_policy_attachment.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot_role/arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role_policy_attachment.lambda_bedrock_backend
  id = "bedrock-slack-ai-chatbot_bedrock-backend-role/arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_bedrock-backend-policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_dynamodb_table.idempotency
  id = "bedrock-slack-ai-chatbot-idempotency"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_sqs_queue.slack_ai_chatbot
  id = "https://sqs.ap-northeast-1.amazonaws.com/172580074565/bedrock-slack-ai-chatbot-queue"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_sqs_queue.slack_ai_chatbot_dlq
  id = "https://sqs.ap-northeast-1.amazonaws.com/172580074565/bedrock-slack-ai-chatbot-dead-letter-queue"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_sqs_queue_redrive_allow_policy.slack_ai_chatbot_redrive_allow_policy
  id = "https://sqs.ap-northeast-1.amazonaws.com/172580074565/bedrock-slack-ai-chatbot-dead-letter-queue"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_api.slack_ai_chatbot
  id = "axk7nbk59l"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_integration.slack_ai_chatbot
  id = "axk7nbk59l/nd3bf2d"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_route.slack_ai_chatbot
  id = "axk7nbk59l/uh41xxo"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_stage.slack_ai_chatbot
  id = "axk7nbk59l/$default"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_bedrock_inference_profile.claude_opus_4_6
  id = "fwye7uon4qq0"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_cloudwatch_log_group.slack_ai_chatbot
  id = "/aws/lambda/bedrock-slack-ai-chatbot"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_cloudwatch_log_group.bedrock_backend
  id = "/aws/lambda/bedrock-slack-ai-chatbot_bedrock-backend"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_cloudwatch_log_group.api_gateway
  id = "/aws/apigateway/bedrock-slack-ai-chatbot"
}

# apply が "Key has already been taken" で失敗した2件。works の PR がマージされる
# 前に、Phase B の手順に沿って UI で手動作成されていたため、新規作成ではなく
# 既存アダプトが必要だった。
import {
  to = tfe_variable.bedrock_slack_ai_chatbot_slack_bot_token
  id = "haruka-aibara/works/var-fkaEBQ2HRia4ZZNy"
}

import {
  to = tfe_variable.bedrock_slack_ai_chatbot_slack_signing_secret
  id = "haruka-aibara/works/var-aJ6VhgiSG2jfRoFH"
}
