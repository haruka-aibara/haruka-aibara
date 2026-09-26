# HVN・Vault クラスターは HCP、ピア側の VPC は AWS に作る。プロバイダーは
# 呼び出し側から渡すこと。ピア側 VPC は aws プロバイダーのリージョンに
# 作られるので、var.region と同じリージョンのプロバイダーを渡す。
terraform {
  required_version = ">= 1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = ">= 0.96"
    }
  }
}
