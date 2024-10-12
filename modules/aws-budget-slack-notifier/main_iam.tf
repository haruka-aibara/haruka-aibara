## For Chatbot
resource "aws_iam_role" "chatbot" {
  name               = "${local.project_name}-chatbot-role"
  assume_role_policy = data.aws_iam_policy_document.chatbot_assume_role.json
}

data "aws_iam_policy_document" "chatbot_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "chatbot" {
  statement {
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:ListSubscriptionsByTopic"
    ]
    resources = [aws_sns_topic.notify_slack.arn]
  }
}

resource "aws_iam_policy" "chatbot" {
  name        = "${local.project_name}-chatbot-policy"
  description = "${local.project_name}-chatbot-policy"
  policy      = data.aws_iam_policy_document.chatbot.json
}

resource "aws_iam_role_policy_attachment" "chatbot" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.chatbot.arn
}
