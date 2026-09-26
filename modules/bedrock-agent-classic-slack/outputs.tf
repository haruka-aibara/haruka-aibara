# Slack で `@Amazon Q connector add` するときに使う
output "agent_arn" {
  description = "エージェントの ARN"
  value       = aws_bedrockagent_agent.this.agent_arn
}

output "agent_alias_id" {
  description = "エージェントのエイリアス ID"
  value       = aws_bedrockagent_agent_alias.this.agent_alias_id
}
