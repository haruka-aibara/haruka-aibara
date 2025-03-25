locals {
  project_name        = "iam-access-analyzer-policy-generate"
  git_repository_name = "https://github.com/haruka-aibara/iam-access-analyzer-policy-generate"

  default_tags = {
    Owner       = "haruka-aibara"
    Terraform   = true
    Environment = var.env
    Project     = local.project_name
    Repository  = local.git_repository_name
  }
}
