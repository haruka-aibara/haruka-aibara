<!-- Space: harukaaibarapublic -->
<!-- Parent: 05-03_メタ引数 -->
<!-- Title: provider メタ引数 -->

# provider メタ引数

リソースが使用するプロバイダーを明示的に指定するメタ引数。複数リージョン・複数アカウントへのデプロイで使う。

---

## 基本的な使い方

`provider` ブロックに `alias` を設定し、リソースで指定する。

```hcl
# デフォルトのプロバイダー（東京）
provider "aws" {
  region = "ap-northeast-1"
}

# エイリアスつきプロバイダー（バージニア）
provider "aws" {
  alias  = "us_east"
  region = "us-east-1"
}

# デフォルト → 東京リージョンに作られる
resource "aws_s3_bucket" "tokyo" {
  bucket = "my-tokyo-bucket"
}

# alias 指定 → バージニアリージョンに作られる
resource "aws_s3_bucket" "virginia" {
  provider = aws.us_east
  bucket   = "my-virginia-bucket"
}
```

---

## 複数アカウントへのデプロイ

```hcl
provider "aws" {
  alias  = "prod"
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/TerraformRole"
  }
}

provider "aws" {
  alias  = "staging"
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::222222222222:role/TerraformRole"
  }
}

resource "aws_vpc" "prod" {
  provider   = aws.prod
  cidr_block = "10.0.0.0/16"
}

resource "aws_vpc" "staging" {
  provider   = aws.staging
  cidr_block = "10.1.0.0/16"
}
```

---

## モジュールへのプロバイダー渡し

モジュールに特定のプロバイダーを渡す場合は `providers` 引数を使う。

```hcl
module "us_resources" {
  source = "./modules/app"
  providers = {
    aws = aws.us_east
  }
}
```
