# 前提: このリージョンで AWS Config のレコーダーが動いていること。
resource "aws_config_config_rule" "policy" {
  for_each = local.policies

  name        = "custodian-${each.key}"
  description = try(each.value.description, null)

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.policy[each.key].arn

    source_detail {
      event_source                = "aws.config"
      message_type                = "ScheduledNotification"
      maximum_execution_frequency = var.schedule
    }
  }

  depends_on = [aws_lambda_permission.config]
}
