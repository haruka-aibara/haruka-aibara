# AWSプロバイダーの設定（東京リージョン）
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = local.default_tags
  }
}

# AWSプロバイダーの設定（バージニア北部）
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = local.default_tags
  }
}
