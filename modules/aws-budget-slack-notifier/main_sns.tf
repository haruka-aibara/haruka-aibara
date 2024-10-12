# AWS Budgets がグローバルサービス（us-east-1）のため、SNSトピックも us-east-1 に作成する必要あり

resource "aws_sns_topic" "slack_alert" {
  provider = aws.us-east-1
  name     = "${local.project_name}_topic"
}

resource "aws_sns_topic_policy" "slack_alert" {
  provider = aws.us-east-1
  arn      = aws_sns_topic.slack_alert.arn
  policy   = data.aws_iam_policy_document.slack_alert.json
}

data "aws_iam_policy_document" "slack_alert" {
  statement {
    sid = "slack_alert"
    actions = [
      "SNS:Publish",
    ]
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
    resources = [
      aws_sns_topic.slack_alert.arn,
    ]
  }
}

