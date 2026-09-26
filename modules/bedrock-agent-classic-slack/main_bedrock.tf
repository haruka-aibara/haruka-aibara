data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_bedrockagent_agent" "this" {
  agent_name              = local.app_name
  agent_resource_role_arn = aws_iam_role.agent.arn
  foundation_model        = local.foundation_model

  description                 = "Slack を介して対話できる AI エージェント"
  idle_session_ttl_in_seconds = 500
  instruction                 = local.instruction
  prepare_agent               = true

  memory_configuration {
    enabled_memory_types = ["SESSION_SUMMARY"]
    storage_days         = 7
  }
}

# Slack 側のコネクターはエイリアスを指すので、エージェントの版が変わったら
# エイリアスごと作り直す（その後 Slack でコネクターも張り直す）。
resource "aws_bedrockagent_agent_alias" "this" {
  agent_alias_name = local.app_name
  agent_id         = aws_bedrockagent_agent.this.agent_id

  lifecycle {
    replace_triggered_by = [
      aws_bedrockagent_agent.this.agent_version
    ]
  }
}
