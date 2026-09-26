resource "aws_chatbot_slack_channel_configuration" "this" {
  configuration_name = local.app_name
  iam_role_arn       = aws_iam_role.chatbot.arn
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_team_id

  # 未指定だと AdministratorAccess がガードレールになるので、ロールと同じ
  # InvokeAgent だけのポリシーで絞る。
  guardrail_policy_arns = [aws_iam_policy.invoke_agent.arn]
}
