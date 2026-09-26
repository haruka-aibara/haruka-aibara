# Config ルールを作るにはこのリージョンに Config のレコーダーが必要（ないと PutConfigRule が
# NoAvailableConfigurationRecorderException で失敗する）。ただし c7n のルールは Config の記録を使わず
# API で直接判定するので、レコーダーは「存在する」だけでよい。記録料金がかからないように、
# 個人アカウントにまず存在しないリソースタイプだけを記録対象にしている。
# レコーダーはリージョンに 1 つしか作れないので、既にある場合はこのファイルを消して既存のものを使う。
resource "aws_config_configuration_recorder" "this" {
  name     = "default"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = false
    include_global_resource_types = false
    resource_types                = ["AWS::Config::ConformancePackCompliance"]

    recording_strategy {
      use_only = "INCLUSION_BY_RESOURCE_TYPES"
    }
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config.bucket

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this]
}

# 記録がほぼ発生しないので中身もほぼ空。SSE-S3（デフォルト）で十分。
# trivy:ignore:AWS-0132
resource "aws_s3_bucket" "config" {
  bucket        = "aws-config-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket = aws_s3_bucket.config.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "config_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "config" {
  name               = "aws-config-recorder"
  assume_role_policy = data.aws_iam_policy_document.config_assume.json
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# 配信先バケットへの書き込み
data "aws_iam_policy_document" "config_delivery" {
  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.config.arn]
  }
  statement {
    actions   = ["s3:PutObject", "s3:PutObjectAcl"]
    resources = ["${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringLike"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_iam_role_policy" "config_delivery" {
  name   = "delivery-channel"
  role   = aws_iam_role.config.id
  policy = data.aws_iam_policy_document.config_delivery.json
}
