data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "custodian_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# 全ポリシーの Lambda で共有する実行ロール。このアカウントの中だけで完結し、他アカウントへの AssumeRole はしない。
resource "aws_iam_role" "custodian" {
  name               = "cloud-custodian-config-rule"
  assume_role_policy = data.aws_iam_policy_document.custodian_assume.json
}

# リソースの読み取り。c7n はフィルタごとに Describe / Get / List 系を呼ぶので、
# 対象サービスが増えても足りるように読み取り専用の SecurityAudit を使う（データそのものは読めない）。
resource "aws_iam_role_policy_attachment" "custodian_security_audit" {
  role       = aws_iam_role.custodian.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "custodian_logs" {
  role       = aws_iam_role.custodian.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 評価結果の書き込みと、削除済みリソースの古い評価の後始末
data "aws_iam_policy_document" "custodian_config" {
  statement {
    actions = [
      "config:PutEvaluations",
      "config:GetComplianceDetailsByConfigRule",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "custodian_config" {
  name   = "config-evaluations"
  role   = aws_iam_role.custodian.id
  policy = data.aws_iam_policy_document.custodian_config.json
}
