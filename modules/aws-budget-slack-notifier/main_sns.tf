# AWS Budgets がグローバルサービス（us-east-1）のため、SNSトピックも us-east-1 に作成する必要あり

# resource "aws_sns_topic" "this" {
#   name = "${local.project_name}_topic"
# }
# 
# resource "aws_sns_topic_policy" "this" {
#   arn = aws_sns_topic.this.arn
# 
#   policy = data.aws_iam_policy_document.sns_topic_policy.json
# }
# 
# data "aws_iam_policy_document" "sns_topic_policy" {
#   statement {
#     actions = [
#       "SNS:Subscribe",
#       "SNS:SetTopicAttributes",
#       "SNS:RemovePermission",
#       "SNS:Receive",
#       "SNS:Publish",
#       "SNS:ListSubscriptionsByTopic",
#       "SNS:GetTopicAttributes",
#       "SNS:DeleteTopic",
#       "SNS:AddPermission",
#     ]
# 
#     condition {
#       test     = "StringEquals"
#       variable = "AWS:SourceOwner"
# 
#       values = [
#         data.aws_caller_identity.current.account_id,
#       ]
#     }
# 
#     effect = "Allow"
# 
#     principals {
#       type        = "AWS"
#       identifiers = ["*"]
#     }
# 
#     resources = [
#       aws_sns_topic.this.arn,
#     ]
#   }
# }
# 
