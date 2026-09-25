variable "repository" {
  description = "Name of the repository (under the provider's owner) whose workflow runs the agent"
  type        = string
}

variable "environment" {
  description = "GitHub Actions environment the workflow job runs in. The role trusts this environment only"
  type        = string
  default     = "jira-to-pr"
}

variable "bedrock_model_id" {
  description = "Bedrock system-defined inference profile id Claude Code runs on"
  type        = string
  default     = "global.anthropic.claude-opus-5-5"
}
