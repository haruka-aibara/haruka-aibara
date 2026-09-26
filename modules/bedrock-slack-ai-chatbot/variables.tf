variable "slack_bot_token" {
  description = "Slack Bot User OAuth Token"
  type        = string
  sensitive   = true
}

variable "slack_signing_secret" {
  description = "Slack Signing Secret"
  type        = string
  sensitive   = true
}

variable "bedrock_max_tokens" {
  # Claude Opus 5.5 cannot turn thinking off, and thinking counts against this limit.
  # Too low a value leaves nothing for the answer itself.
  description = "Maximum number of tokens Bedrock may generate per response, thinking included"
  type        = number
  default     = 16000
}
