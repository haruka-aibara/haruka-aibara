# Lets the Jira-to-PR workflow run Claude Code on Bedrock with no stored AWS keys:
# GitHub Actions presents an OIDC token and assumes this role for the length of
# the job. What the workflow does and how it is wired up:
# docs/runbooks/jira-to-pr.md

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "github_repository" "this" {
  name = var.repository
}

locals {
  name = "jira-to-pr"

  # The chatbot's default_tags on the provider would label this as its resources,
  # so the Project tag is overridden here. Resource tags win over default_tags.
  tags = {
    Project = local.name
  }

  # The system-defined profile's id is the model id with a geography prefix.
  foundation_model = trimprefix(var.bedrock_model_id, "global.")
}

# One provider per URL per account. HCP Terraform's own OIDC provider
# (app.terraform.io) is a different URL, so the two do not collide.
resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags           = local.tags
}

# Only jobs that declare the environment can assume the role, and the
# environment itself only admits protected branches (see the root module), so a
# workflow edited on a feature branch cannot reach Bedrock.
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${data.github_repository.this.full_name}:environment:${var.environment}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name                 = "${local.name}-github-actions"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  max_session_duration = 3600
  tags                 = local.tags

  depends_on = [aws_iam_openid_connect_provider.github_actions]
}

# Bedrock only. The role reads nothing else in the account, so an agent talked
# into misbehaving by a ticket has nothing in AWS to reach for.
data "aws_iam_policy_document" "bedrock" {
  statement {
    sid    = "invoke"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:inference-profile/${var.bedrock_model_id}",
      # A global profile routes to any region, and is authorized against the
      # model in whichever region serves the call as well as the region-less ARN.
      "arn:aws:bedrock:*::foundation-model/${local.foundation_model}",
      "arn:aws:bedrock:::foundation-model/${local.foundation_model}",
    ]
  }

  # Claude Code looks up inference profiles at startup to resolve the model.
  statement {
    sid    = "profiles"
    effect = "Allow"
    actions = [
      "bedrock:GetInferenceProfile",
      "bedrock:ListInferenceProfiles",
    ]
    resources = [
      "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:inference-profile/*",
    ]
  }
}

resource "aws_iam_role_policy" "bedrock" {
  name   = "bedrock"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.bedrock.json
}

# Secrets and variables the job reads live on this environment, so no other
# workflow in the repository can read them. Their values are set in the UI; see
# the runbook. Only protected branches (main) may deploy to it.
resource "github_repository_environment" "this" {
  repository  = var.repository
  environment = var.environment

  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
