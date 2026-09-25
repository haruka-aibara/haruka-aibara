variable "name" {
  type        = string
  description = "Prefix for resource names (IAM role/policy, SNS topic, KMS alias, Chatbot configuration)"
  default     = "terraform-aws-budget-slack-notifier"
}

variable "slack_channel_id" {
  type        = string
  description = "The ID of the Slack channel"
}

variable "slack_workspace_id" {
  type        = string
  description = "The ID of the Slack workspace"
}

variable "budgets_limit_amount_daily" {
  type        = number
  description = "limit amount of aws budgets"
}
