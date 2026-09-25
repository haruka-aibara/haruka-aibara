locals {
  project_name        = "aws-cost-allocation-tags"
  git_repository_name = "https://github.com/haruka-aibara/aws-cost-allocation-tags"

  default_tags = {
    Owner       = "haruka-aibara"
    Terraform   = true
    Environment = var.env
    Project     = local.project_name
    Repository  = local.git_repository_name
  }
}
