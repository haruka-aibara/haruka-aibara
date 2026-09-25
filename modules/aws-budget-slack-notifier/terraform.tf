# AWS Budgets はグローバルサービス（us-east-1）なので、SNS トピックと KMS キーは
# aws.us-east-1 で作る。呼び出し側で us-east-1 のプロバイダーを渡すこと。
terraform {
  required_version = ">= 1.9.6"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}
