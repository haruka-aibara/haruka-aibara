# AWS Budgets がグローバルサービス（us-east-1）のため、SNSトピックも us-east-1 に作成する必要あり

resource "aws_sns_topic" "notify_slack" {
  provider = aws.us-east-1
  name     = "${local.project_name}_topic"
}

resource "aws_sns_topic_policy" "notify_slack" {
  provider = aws.us-east-1
  arn      = aws_sns_topic.notify_slack.arn
  policy   = data.aws_iam_policy_document.notify_slack.json
}

data "aws_iam_policy_document" "notify_slack" {
  statement {
    sid = "notify_slack"
    actions = [
      "SNS:Publish",
    ]
    effect = "Allow"
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }
    resources = [
      aws_sns_topic.notify_slack.arn,
    ]
  }
}

