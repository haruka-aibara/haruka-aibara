locals {
  app_name = "bedrock-slack-ai-agent"

  foundation_model = "anthropic.claude-3-haiku-20240307-v1:0"
  instruction      = "質問内容に簡潔かつ的確に答えてください。不要な前置きは避け、ユーザーの意図を理解し、具体的で役立つ情報を提供することに集中してください。必要に応じて、追加の詳細や説明を提案することも可能です。"
}
