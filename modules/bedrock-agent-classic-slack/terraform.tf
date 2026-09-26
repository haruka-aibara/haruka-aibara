terraform {
  # works のルートモジュールから呼ぶ子モジュール。backend と provider の設定は
  # ルート（../../terraform.tf, ../../providers.tf）にだけ置く。
  required_version = ">= 1.9.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
