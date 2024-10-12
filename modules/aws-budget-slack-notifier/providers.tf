# AWSプロバイダーの設定（東京リージョン）
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Owner       = "haruka-aibara"
      Terraform   = true
      Environment = var.env
      Project     = local.project_name
      Repository  = local.git_repository_name
    }
  }
}
