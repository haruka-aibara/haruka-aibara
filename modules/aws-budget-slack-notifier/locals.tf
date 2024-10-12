locals {
  project_name        = "terraform-aws-budget-slack-notifier"
  git_repository_name = "https://github.com/haruka-aibara/terraform-aws-budget-slack-notifier"
  slack_channel_id    = var.slack_channel_id
  slack_workspace_id  = var.slack_workspace_id
}
