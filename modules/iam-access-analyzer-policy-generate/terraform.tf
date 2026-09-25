terraform {
  cloud {
    organization = "haruka-aibara"
    workspaces {
      name = "iam-access-analyzer-policy-generate"
    }
  }

  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72.1"
    }
  }
}
