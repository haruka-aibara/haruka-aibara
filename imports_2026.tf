# =========================================
# bedrock-slack-ai-chatbot state 統合
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
