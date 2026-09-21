# =========================================
# HCP Terraform Management
# =========================================

# The VCS connection is an organization-level OAuth client, not the GitHub App
# HCP Terraform offers by default. The App ties "may this caller connect that
# repository" to a person's GitHub account, which no API token this
# configuration can issue for itself ever has -- see
# docs/reference/github-authentication.md for why that ruled the App out.
#
# vcs_repo wants the OAuth *token* id (ot-...), which belongs to the client
# (oc-...). Look it up rather than storing it: re-authorizing the connection
# mints a new token id, and this way that costs no edit here.
data "tfe_oauth_client" "this" {
  organization     = local.tfe_organization
  service_provider = "github"
}

# AWS Cost Allocation Tags Workspace
resource "tfe_workspace" "aws-cost-allocation-tags" {
  name                          = "aws-cost-allocation-tags"
  organization                  = local.tfe_organization
  description                   = "aws cost allocation tags"
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "1.16.3"

  vcs_repo {
    identifier         = "${local.github_owner}/aws-cost-allocation-tags"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}

# Bedrock Slack AI Agent Workspace
resource "tfe_workspace" "bedrock-slack-ai-agent" {
  name                          = "bedrock-slack-ai-agent"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "1.16.3"

  vcs_repo {
    identifier         = "${local.github_owner}/bedrock-slack-ai-agent"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}

# Bedrock Slack AI Chatbot Workspace -- being decommissioned now that its AWS
# infra is imported into module.bedrock_slack_ai_chatbot_infra (see
# docs/runbooks/bedrock-slack-ai-chatbot-state-merge.md). force_delete is set
# here first so it lands in state; only once that's applied is it safe to
# remove this block entirely in a follow-up PR, otherwise the destroy call
# would still hit HCP Terraform's default safe-delete and fail because this
# workspace's own state still lists resources.
resource "tfe_workspace" "bedrock-slack-ai-chatbot" {
  name                          = "bedrock-slack-ai-chatbot"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "~> 1.16.0"
  force_delete                  = true

  vcs_repo {
    identifier         = "${local.github_owner}/bedrock-slack-ai-chatbot"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}

# Deploy HCP Vault Dedicated with Terraform Workspace
resource "tfe_workspace" "deploy-hcp-vault-dedicated-with-terraform" {
  name                          = "deploy-hcp-vault-dedicated-with-terraform"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "1.16.3"

  vcs_repo {
    identifier         = "${local.github_owner}/deploy-hcp-vault-dedicated-with-terraform"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}

# Generate Dev IO Summary Workspace
resource "tfe_workspace" "generate-dev-io-summary" {
  name                          = "generate-dev-io-summary"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "1.16.3"

  vcs_repo {
    identifier         = "${local.github_owner}/generate-dev-io-summary"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}

# Haruka Aibara Workspace
resource "tfe_workspace" "works" {
  name                          = "works"
  organization                  = local.tfe_organization
  description                   = "Terraform-managed GitHub repositories and HCP Terraform workspaces"
  auto_apply                    = true
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "~> 1.16.0"

  vcs_repo {
    identifier         = "${local.github_owner}/works"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}

# IAM Access Analyzer Policy Generate Workspace
resource "tfe_workspace" "iam-access-analyzer-policy-generate" {
  name                          = "iam-access-analyzer-policy-generate"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "1.16.3"

  vcs_repo {
    identifier         = "${local.github_owner}/iam-access-analyzer-policy-generate"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}

# Terraform AWS Budget Slack Notifier Workspace
resource "tfe_workspace" "terraform-aws-budget-slack-notifier" {
  name                          = "terraform-aws-budget-slack-notifier"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "1.16.3"

  vcs_repo {
    identifier         = "${local.github_owner}/terraform-aws-budget-slack-notifier"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}


# Google Cloud Hands-on Workspace
resource "tfe_workspace" "google-cloud-hands-on" {
  name                          = "google-cloud-hands-on"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "1.16.3"

  vcs_repo {
    identifier         = "${local.github_owner}/google-cloud-hands-on"
    oauth_token_id     = local.oauth_token_id
    ingress_submodules = false
  }
}
