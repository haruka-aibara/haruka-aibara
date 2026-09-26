# エージェント実行ロール: 基盤モデルの呼び出しだけを許可する
resource "aws_iam_role" "agent" {
  name_prefix        = "AmazonBedrockExecutionRoleForAgents_"
  assume_role_policy = data.aws_iam_policy_document.agent_trust.json
}

data "aws_iam_policy_document" "agent_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:agent/*"]
    }
  }
}

resource "aws_iam_role_policy" "agent" {
  role   = aws_iam_role.agent.id
  policy = data.aws_iam_policy_document.agent.json
}

data "aws_iam_policy_document" "agent" {
  statement {
    actions   = ["bedrock:InvokeModel"]
    resources = ["arn:${data.aws_partition.current.partition}:bedrock:${data.aws_region.current.region}::foundation-model/${local.foundation_model}"]
  }
}

# Chatbot ロール: このエージェントのエイリアスへの InvokeAgent だけを許可する
resource "aws_iam_role" "chatbot" {
  name_prefix        = "ChatbotRole_"
  assume_role_policy = data.aws_iam_policy_document.chatbot_trust.json
}

data "aws_iam_policy_document" "chatbot_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["chatbot.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "chatbot_invoke_agent" {
  role       = aws_iam_role.chatbot.name
  policy_arn = aws_iam_policy.invoke_agent.arn
}

resource "aws_iam_policy" "invoke_agent" {
  name        = "${local.app_name}-bedrock-invoke-agent-policy"
  description = "Allows bedrock:InvokeAgent on specific agent alias"
  policy      = data.aws_iam_policy_document.invoke_agent.json
}

data "aws_iam_policy_document" "invoke_agent" {
  statement {
    actions   = ["bedrock:InvokeAgent"]
    resources = [aws_bedrockagent_agent_alias.this.agent_alias_arn]
  }
}
