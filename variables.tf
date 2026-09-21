variable "bedrock_slack_ai_chatbot_slack_bot_token" {
  description = "Slack Bot User OAuth Token for the bedrock-slack-ai-chatbot module"
  type        = string
  sensitive   = true
}

variable "bedrock_slack_ai_chatbot_slack_signing_secret" {
  description = "Slack Signing Secret for the bedrock-slack-ai-chatbot module"
  type        = string
  sensitive   = true
}
