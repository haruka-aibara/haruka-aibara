locals {
  project_name        = "terraform-aws-budget-slack-notifier"
  git_repository_name = "https://github.com/haruka-aibara/terraform-aws-budget-slack-notifier"

  default_tags = {
    Owner       = "haruka-aibara"
    Terraform   = true
    Environment = var.env
    Project     = local.project_name
    Repository  = local.git_repository_name
  }
}
