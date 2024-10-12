# AWS プロバイダーは実装時のメジャーバージョンの最新以上を使用するよう定義
terraform {
  cloud {
    organization = "haruka-aibara"
    workspaces {
      name = "terraform-aws-budget-slack-notifier"
    }
  }

  required_version = ">= 1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
