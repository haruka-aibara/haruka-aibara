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

# The short-cycle verification in docs/runbooks/tfe-token-rotation.md sets these
# as workspace Terraform variables, so they stay declared at the root. Left
# unset (null), module "tfe_token_rotation" falls back to its own defaults.
variable "rotation_minutes" {
  type        = number
  description = "Overrides module.tfe_token_rotation's rotation_minutes. Leave unset outside the short-cycle verification."
  default     = null
}

variable "buffer_minutes" {
  type        = number
  description = "Overrides module.tfe_token_rotation's buffer_minutes. Leave unset outside the short-cycle verification."
  default     = null
}
