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

# =========================================
# Workspace variables (works)
# =========================================
# The github provider reads GitHub App credentials from GITHUB_APP_* environment
# variables, so switching away from a PAT needs no provider block change.
#
# What these credentials are, and why the setup looks like this:
# docs/reference/github-authentication.md
#
# Terraform declares these variables; the UI holds their values. The placeholder
# below is written once, at creation, and is then left alone: HCP Terraform never
# returns a sensitive variable's value, so the provider carries the last known
# state value forward on every read and only ever writes a new one if `value`
# changes here. No ignore_changes is needed for that — it is how the provider
# treats sensitive variables.
#
# The consequence is that Terraform cannot see these values at all. It will not
# detect a key cleared or corrupted in the UI, and a plan stays clean either way.
#
# The private key has to be handled this way, since a value written here would
# land in state. The ids do not — only the private key can sign a token request,
# so neither identifier opens anything on its own — but they take the same shape
# so there is one rule rather than two, and so this public repository names
# nothing about the organization's App.

resource "tfe_variable" "github_app_id" {
  workspace_id = tfe_workspace.works.id
  key          = "GITHUB_APP_ID"
  value        = "set-in-ui"
  category     = "env"
  sensitive    = true
  description  = "GitHub App ID. Set this value in the UI."
}

resource "tfe_variable" "github_app_installation_id" {
  workspace_id = tfe_workspace.works.id
  key          = "GITHUB_APP_INSTALLATION_ID"
  value        = "set-in-ui"
  category     = "env"
  sensitive    = true
  description  = "Installation ID of the GitHub App on the organization. Set this value in the UI."
}

resource "tfe_variable" "github_app_pem_file" {
  workspace_id = tfe_workspace.works.id
  key          = "GITHUB_APP_PEM_FILE"
  value        = "set-in-ui"
  category     = "env"
  sensitive    = true
  description  = "GitHub App private key (PEM). Set this value in the UI."
}

# =========================================
# bedrock-slack-ai-chatbot module credentials
# =========================================
# Same reasoning as the GitHub App variables above: HCP Terraform never
# returns a sensitive variable's value, so these are declared once with a
# placeholder and the real value is set in the UI afterward.
#
# AWS itself is authenticated via dynamic provider credentials (OIDC), not
# static keys -- see providers.tf -- so there is no AWS_ACCESS_KEY_ID /
# AWS_SECRET_ACCESS_KEY here.
#
# ignore_changes on value: these two were created by hand in the UI before
# this code landed, so they were adopted with an `import` block (see
# imports.tf) rather than created fresh. HCP Terraform never returns a
# sensitive value, so after import the provider has no way to know it already
# matches "set-in-ui" and would otherwise plan to overwrite the real secret
# with the placeholder. ignore_changes makes that impossible, since neither
# is meant to be written from code again after their first value is set in
# the UI.

resource "tfe_variable" "bedrock_slack_ai_chatbot_slack_bot_token" {
  workspace_id = tfe_workspace.works.id
  key          = "bedrock_slack_ai_chatbot_slack_bot_token"
  value        = "set-in-ui"
  category     = "terraform"
  sensitive    = true
  description  = "Slack Bot User OAuth Token for the bedrock-slack-ai-chatbot module. Set this value in the UI."

  lifecycle {
    ignore_changes = [value]
  }
}

resource "tfe_variable" "bedrock_slack_ai_chatbot_slack_signing_secret" {
  workspace_id = tfe_workspace.works.id
  key          = "bedrock_slack_ai_chatbot_slack_signing_secret"
  value        = "set-in-ui"
  category     = "terraform"
  sensitive    = true
  description  = "Slack Signing Secret for the bedrock-slack-ai-chatbot module. Set this value in the UI."

  lifecycle {
    ignore_changes = [value]
  }
}

# =========================================
# TFE_TOKEN rotation
# =========================================

# TFE_TOKEN self-rotation (blue / green). The how and why are in the module and
# docs/runbooks/tfe-token-rotation.md.
module "tfe_team_token_rotation" {
  source = "./modules/tfe-team-token-rotation"

  organization = local.tfe_organization
  workspace_id = tfe_workspace.works.id

  rotation_minutes = var.rotation_minutes
  buffer_minutes   = var.buffer_minutes

  # Bump one to rotate that colour now -- only ever the one NOT in use.
  blue_serial  = 1
  green_serial = 1
}
