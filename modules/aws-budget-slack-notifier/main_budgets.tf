resource "aws_budgets_budget" "all_daily" {
  name         = "budget-all-daily"
  budget_type  = "COST"
  limit_amount = var.budgets_limit_amount_daily
  limit_unit   = "USD"
  time_unit    = "DAILY"

  notification {
    notification_type         = "ACTUAL"
    comparison_operator       = "GREATER_THAN"
    threshold                 = var.budgets_limit_amount_daily
    threshold_type            = "ABSOLUTE_VALUE"
    subscriber_sns_topic_arns = [aws_sns_topic.notify_slack.arn]
  }
}
