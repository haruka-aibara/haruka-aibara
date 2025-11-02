# =========================================
# HCP Terraform Management
# =========================================

# AWS Cost Allocation Tags Workspace
resource "tfe_workspace" "aws-cost-allocation-tags" {
  name                   = "aws-cost-allocation-tags"
  organization           = local.tfe_organization
  description            = "aws cost allocation tags"
  auto_apply             = true
  auto_apply_run_trigger = true
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "1.9.8"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/aws-cost-allocation-tags"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# Bedrock Slack AI Agent Workspace
resource "tfe_workspace" "bedrock-slack-ai-agent" {
  name                   = "bedrock-slack-ai-agent"
  organization           = local.tfe_organization
  auto_apply             = true
  auto_apply_run_trigger = false
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "1.9.6"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/bedrock-slack-ai-agent"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# Bedrock Slack AI Chatbot Workspace
resource "tfe_workspace" "bedrock-slack-ai-chatbot" {
  name                   = "bedrock-slack-ai-chatbot"
  organization           = local.tfe_organization
  auto_apply             = true
  auto_apply_run_trigger = true
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "~>1.13.0"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/bedrock-slack-ai-chatbot"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# Deploy HCP Vault Dedicated with Terraform Workspace
resource "tfe_workspace" "deploy-hcp-vault-dedicated-with-terraform" {
  name                   = "deploy-hcp-vault-dedicated-with-terraform"
  organization           = local.tfe_organization
  auto_apply             = false
  auto_apply_run_trigger = false
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "1.9.6"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/deploy-hcp-vault-dedicated-with-terraform"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# Generate Dev IO Summary Workspace
resource "tfe_workspace" "generate-dev-io-summary" {
  name                   = "generate-dev-io-summary"
  organization           = local.tfe_organization
  auto_apply             = true
  auto_apply_run_trigger = true
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "1.9.6"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/generate-dev-io-summary"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# Haruka Aibara Workspace
resource "tfe_workspace" "haruka-aibara" {
  name                   = "haruka-aibara"
  organization           = local.tfe_organization
  description            = "haruka-aibara"
  auto_apply             = true
  auto_apply_run_trigger = false
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "~>1.13.0"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/haruka-aibara"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# IAM Access Analyzer Policy Generate Workspace
resource "tfe_workspace" "iam-access-analyzer-policy-generate" {
  name                   = "iam-access-analyzer-policy-generate"
  organization           = local.tfe_organization
  auto_apply             = true
  auto_apply_run_trigger = true
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "1.11.2"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/iam-access-analyzer-policy-generate"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# Terraform AWS Budget Slack Notifier Workspace
resource "tfe_workspace" "terraform-aws-budget-slack-notifier" {
  name                   = "terraform-aws-budget-slack-notifier"
  organization           = local.tfe_organization
  auto_apply             = true
  auto_apply_run_trigger = true
  file_triggers_enabled  = false
  queue_all_runs         = false
  terraform_version      = "1.9.7"

  vcs_repo {
    identifier                 = "${local.tfe_organization}/terraform-aws-budget-slack-notifier"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

