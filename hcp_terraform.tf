# =========================================
# HCP Terraform Management
# =========================================

# vcs_repo.github_app_installation_id wants HCP Terraform's own identifier for
# the installation (ghain-...), not GitHub's numeric installation id from the
# settings URL. Look it up by the account the app is installed on, so
# reinstalling the app does not require editing a stored value.
data "tfe_github_app_installation" "this" {
  name = local.github_owner
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
    identifier                 = "${local.github_owner}/aws-cost-allocation-tags"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
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
    identifier                 = "${local.github_owner}/bedrock-slack-ai-agent"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}

# Bedrock Slack AI Chatbot Workspace
resource "tfe_workspace" "bedrock-slack-ai-chatbot" {
  name                          = "bedrock-slack-ai-chatbot"
  organization                  = local.tfe_organization
  auto_apply                    = false
  auto_apply_run_trigger        = false
  file_triggers_enabled         = false
  queue_all_runs                = false
  structured_run_output_enabled = false
  terraform_version             = "~> 1.16.0"

  vcs_repo {
    identifier                 = "${local.github_owner}/bedrock-slack-ai-chatbot"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
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
    identifier                 = "${local.github_owner}/deploy-hcp-vault-dedicated-with-terraform"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
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
    identifier                 = "${local.github_owner}/generate-dev-io-summary"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
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
    identifier                 = "${local.github_owner}/works"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
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
    identifier                 = "${local.github_owner}/iam-access-analyzer-policy-generate"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
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
    identifier                 = "${local.github_owner}/terraform-aws-budget-slack-notifier"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
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
    identifier                 = "${local.github_owner}/google-cloud-hands-on"
    github_app_installation_id = local.github_app_installation_id
    ingress_submodules         = false
  }
}
