resource "aws_budgets_budget" "all_daily" {
  name         = "budget-all-daily"
  budget_type  = "COST"
  limit_amount = local.budgets_limit_ammout
  limit_unit   = "USD"
  time_unit    = "DAILY"

  notification {
    notification_type         = "ACTUAL"
    comparison_operator       = "GREATER_THAN"
    threshold                 = local.budgets_limit_ammout
    threshold_type            = "ABSOLUTE_VALUE"
    subscriber_sns_topic_arns = [aws_sns_topic.notify_slack.arn]
  }
}
