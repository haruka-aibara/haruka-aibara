# SNS トピックの保管時暗号化に使用する KMS キー
# AWS マネージドキー（alias/aws/sns）はキーポリシーを編集できず
# AWS Budgets からの publish を許可できないため、カスタマーマネージドキーを使用する
resource "aws_kms_key" "notify_slack" {
  provider                = aws.us-east-1
  description             = "${local.project_name} SNS topic encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.notify_slack_kms.json
}

resource "aws_kms_alias" "notify_slack" {
  provider      = aws.us-east-1
  name          = "alias/${local.project_name}"
  target_key_id = aws_kms_key.notify_slack.key_id
}

data "aws_iam_policy_document" "notify_slack_kms" {
  # キーポリシーでアカウントルートを許可しないと IAM 側で権限を委譲できなくなる
  statement {
    sid       = "EnableIAMUserPermissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # 暗号化されたトピックへ publish するため Budgets にデータキーの利用を許可する
  # サブスクライバ（Chatbot）は SNS が配信前に復号するため KMS 権限は不要
  statement {
    sid    = "AllowBudgetsToPublishToEncryptedTopic"
    effect = "Allow"
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["budgets.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}
