# =========================================
# for personal use only
# =========================================

# Terraform meta repository (monorepo)
# Renamed from "haruka-aibara" and transferred to the organization. The old
# owner/name combination is retired by GitHub and cannot be reused.
module "haruka-aibara" {
  source = "./modules/repository"

  repository_name = "works"
  description     = "Personal monorepo: Terraform for GitHub repos and HCP Terraform workspaces, shared CI, learning notes/articles, and devcontainer templates"
  homepage_url    = "https://haruka-aibara.github.io/works/"

  topics = ["terraform", "github", "iac"]

  # docs/ absorbed the old standalone "docs" repository, .nojekyll included, so
  # Pages now publishes straight from this branch/folder instead of a separate repo.
  pages = {
    branch = "main"
    path   = "/docs"
  }
}

# =========================================
# My Slack AI Integration Projects
# =========================================

# DevelopersIO Article Summarizer with Slack Notifications
module "generate-dev-io-summary" {
  source = "./modules/repository"

  repository_name = "generate-dev-io-summary"
  description     = "Summarize new articles posted on DevelopersIO and send email notifications"

  topics = ["terraform", "aws", "generative-ai"]
}

# Thread-aware Bedrock Chatbot — application infrastructure.
# Absorbed from the standalone bedrock-slack-ai-chatbot repository/workspace;
# see docs/runbooks/bedrock-slack-ai-chatbot-state-merge.md for the migration.
module "bedrock_slack_ai_chatbot_infra" {
  source = "./modules/bedrock-slack-ai-chatbot"

  slack_bot_token      = var.bedrock_slack_ai_chatbot_slack_bot_token
  slack_signing_secret = var.bedrock_slack_ai_chatbot_slack_signing_secret
}

# Multi-turn Bedrock AI Agent
module "bedrock-slack-ai-agent" {
  source = "./modules/repository"

  repository_name = "bedrock-slack-ai-agent"
  description     = "A Slack AI agent using Amazon Bedrock with continuous conversation history"

  topics = ["aws", "bedrock", "slack", "generative-ai", "chatbot"]
}

# =========================================
# My AWS Projects
# =========================================

# AWS Budget Slack Notifications
module "terraform-aws-budget-slack-notifier" {
  source = "./modules/repository"

  repository_name = "terraform-aws-budget-slack-notifier"
  description     = "Send AWS Budget notifications to Slack"

  topics = ["terraform", "aws", "budget", "slack"]
}

# AWS Cost Management
module "aws-cost-allocation-tags" {
  source = "./modules/repository"

  repository_name = "aws-cost-allocation-tags"
  description     = "Manage AWS Cost Allocation Tags"

  topics = ["terraform", "aws", "cost", "tags"]
}

# =========================================
# My AWS Learning Repositories
# =========================================

# AWS Config Custom Rules
module "aws-custom-lambda-config-rules" {
  source = "./modules/repository"

  repository_name = "aws-custom-lambda-config-rules"
  description     = "Customize AWS Config Rules using Lambda"

  topics = ["terraform", "aws", "lambda", "config"]
}

# IAM Policy Analysis
module "iam-access-analyzer-policy-generate" {
  source = "./modules/repository"

  repository_name = "iam-access-analyzer-policy-generate"
  description     = "Experiment with IAM Access Analyzer policy generation"

  topics = ["aws", "iam", "access-analyzer", "policy"]
}

# =========================================
# My HCP Vault Learning Repositories
# =========================================

# HCP Vault Deployment
module "deploy-hcp-vault-dedicated-with-terraform" {
  source = "./modules/repository"

  repository_name = "deploy-hcp-vault-dedicated-with-terraform"
  description     = "Deploy HashiCorp Cloud Platform (HCP) Vault Dedicated cluster using Terraform"

  topics = ["terraform", "vault", "hcp", "hashicorp"]
}

# =========================================
# My Development Environment Repositories   
# =========================================

# VS Code DevContainer Templates
# テンプレートの定義とリリースは devcontainer-templates/ に移した。このリポジトリは
# ロールバック先兼、旧 ghcr package の置き場として残してある。畳む手順は
# docs/runbooks/devcontainer-template-monorepo-migration.md。
module "devcontainer-templates" {
  source = "./modules/repository"

  repository_name = "devcontainer-templates"
  description     = "DevContainer templates for development environments"

  topics = ["devcontainer", "vscode", "development"]
}

# =========================================
# My Docker Learning Repositories
# =========================================

# Docker CI/CD sample Example
module "docker-simple-cicd-demo" {
  source = "./modules/repository"

  repository_name = "docker-simple-cicd-demo"
  description     = "Simple CI/CD demo using Docker"

  topics = ["docker", "cicd", "devops"]
}

# Docker Hello World Example
module "docker-hello-world" {
  source = "./modules/repository"

  repository_name = "docker-hello-world"
  description     = "A simple Docker Hello World example demonstrating basic Docker concepts"

  topics = ["docker", "hello-world", "getting-started"]
}

# =========================================
# My GitHub Actions Learning Repositories
# =========================================

# Basic GitHub Actions Testing
module "github-actions-test" {
  source = "./modules/repository"

  repository_name = "github-actions-test"
  description     = "GitHub Actions testing"

  topics = ["github-actions", "ci", "cd"]
}

# Jobs, Artifacts, and Outputs
module "github-actions-test-jobs-artifacts-outputs" {
  source = "./modules/repository"

  repository_name = "github-actions-test-jobs-artifacts-outputs"
  description     = "Testing GitHub Actions jobs, artifacts, and outputs"

  topics = ["github-actions", "ci", "cd", "jobs", "artifacts", "outputs"]
}

# GitHub Actions Events
module "github-actions-test-events-deep-dive" {
  source = "./modules/repository"

  repository_name = "github-actions-test-events-deep-dive"
  description     = "Deep dive into GitHub Actions events"

  topics = ["github-actions", "ci", "cd", "events"]
}

# CI/CD Pipeline Testing
module "github-actions-test-lint-test-deploy-build" {
  source = "./modules/repository"

  repository_name = "github-actions-test-lint-test-deploy-build"
  description     = "GitHub Actions lint, test, deploy, and build testing"

  topics = ["github-actions", "ci", "cd", "lint", "test", "deploy"]
}

# React Application CI/CD
module "github-actions-test-react-demo" {
  source = "./modules/repository"

  repository_name = "github-actions-test-react-demo"
  description     = "GitHub Actions React demo"

  topics = ["github-actions", "react", "ci", "cd"]
}

# GitHub Actions Environment Variables
module "github-actions-test-env-vars" {
  source = "./modules/repository"

  repository_name = "github-actions-test-env-vars"
  description     = "Testing GitHub Actions environment variables and secrets"

  topics = ["github-actions", "ci", "cd", "environment-variables", "secrets"]
}

# GitHub Actions Workflow Controls
module "github-actions-test-workflow-controls" {
  source = "./modules/repository"

  repository_name = "github-actions-test-workflow-controls"
  description     = "Testing GitHub Actions workflow controls including conditional jobs and steps"

  topics = ["github-actions", "ci", "cd", "workflow", "conditional-jobs", "conditional-steps"]
}

# GitHub Actions Container Jobs
module "github-actions-test-container-jobs" {
  source = "./modules/repository"

  repository_name = "github-actions-test-container-jobs"
  description     = "Testing GitHub Actions jobs running in containers"

  topics = ["github-actions", "ci", "cd", "containers", "docker"]
}

# GitHub Actions Custom Actions
module "github-actions-test-custom-actions" {
  source = "./modules/repository"

  repository_name = "github-actions-test-custom-actions"
  description     = "Testing GitHub Actions custom actions development and usage"

  topics = ["github-actions", "ci", "cd", "custom-actions", "reusable-workflows"]
}

# GitHub Actions Security
module "github-actions-test-security" {
  source = "./modules/repository"

  repository_name = "github-actions-test-security"
  description     = "Testing GitHub Actions security features, permissions, and best practices"

  topics = ["github-actions", "ci", "cd", "security", "permissions", "best-practices"]
}

# =========================================
# My Monitoring Learning Repositories
# =========================================

# Grafana and Prometheus Monitoring Hands-on
module "grafana-prometheus-monitoring-hands-on" {
  source = "./modules/repository"

  repository_name = "grafana-prometheus-monitoring-hands-on"
  description     = "Hands-on practice repository for monitoring with Grafana and Prometheus"

  topics = ["monitoring", "grafana", "prometheus", "observability", "metrics"]
}

# =========================================
# Terraform
# =========================================

# Terraform Modules Hands-on
module "terraform-modules-hands-on" {
  source = "./modules/repository"

  repository_name = "terraform-modules-hands-on"
  description     = "Hands-on practice repository for learning Terraform modules with practical examples"

  topics = ["terraform", "modules", "infrastructure-as-code", "iac", "hands-on", "learning"]
}

# Terraform Hands-on Practice
module "terraform-hands-on" {
  source = "./modules/repository"

  repository_name = "terraform-hands-on"
  description     = "General Terraform hands-on practice repository with various examples and use cases"

  topics = ["terraform", "infrastructure-as-code", "iac", "hands-on", "aws", "azure", "gcp"]
}

# Terraform IAM User Hands-on
module "terraform-iam-user-hands-on" {
  source = "./modules/repository"

  repository_name = "terraform-iam-user-hands-on"
  description     = "Hands-on practice repository for managing IAM users with Terraform"

  topics = ["terraform", "aws", "iam", "user-management", "hands-on", "learning"]
}

# Terraform fmt CI
module "terraform-fmt-github-actions-ci" {
  source = "./modules/repository"

  repository_name = "terraform-fmt-github-actions-ci"
  description     = "GitHub Actions workflow YAML for terraform fmt ci"

  topics = ["terraform", "fmt", "github-actions", "ci", "automation"]
}

# =========================================
# My Google Cloud Learning Repositories
# =========================================

# Google Cloud Hands-on Practice
module "google-cloud-hands-on" {
  source = "./modules/repository"

  repository_name = "google-cloud-hands-on"
  description     = "Hands-on practice repository for learning Google Cloud with gcloud CLI and various Google Cloud services"

  topics = ["google-cloud", "gcloud", "hands-on", "learning", "cloud"]
}

# =========================================
# Python
# =========================================

# Selenium Edge Automation
module "selenium-edge-automation" {
  source = "./modules/repository"

  repository_name = "selenium-edge-automation"
  description     = "Python automation testing with Selenium and Microsoft Edge"

  topics = ["python", "selenium", "edge", "automation", "testing", "webdriver"]
}

# =========================================
# Shared CI / GitHub Actions
# =========================================

# Reusable GitHub Actions workflows (Terraform CI logic single source)
module "github-actions" {
  source = "./modules/repository"

  repository_name = "github-actions"
  description     = "Shared reusable GitHub Actions workflows (Terraform CI etc.)"

  topics = ["github-actions", "ci", "terraform"]
}

# =========================================
# Terraform CI distribution
# Reusable workflow body + per-repo caller files,
# all managed from this repo as the single source.
# =========================================

# Push the reusable workflow body into the github-actions repo.
resource "github_repository_file" "reusable_terraform_ci" {
  repository          = module.github-actions.repository_name
  branch              = "main"
  file                = ".github/workflows/terraform-ci.yml"
  content             = file("${path.module}/ci/workflows/terraform-ci.yml")
  commit_message      = "Update reusable Terraform CI workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}

# Distribute the thin caller workflow to each Terraform repository.
resource "github_repository_file" "terraform_ci_caller" {
  for_each = local.terraform_ci_repos

  depends_on = [github_repository_file.reusable_terraform_ci]

  repository = each.key
  branch     = "main"
  file       = ".github/workflows/terraform-ci.yml"
  content = templatefile("${path.module}/ci/templates/terraform-ci-caller.yml.tftpl", {
    working_directory = each.value.working_directory
  })
  commit_message      = "Add Terraform CI caller workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}

# =========================================
# Python CI distribution
# Reusable workflow body + per-repo caller files,
# all managed from this repo as the single source.
# =========================================

# Push the reusable workflow body into the github-actions repo.
resource "github_repository_file" "reusable_python_ci" {
  repository          = module.github-actions.repository_name
  branch              = "main"
  file                = ".github/workflows/python-ci.yml"
  content             = file("${path.module}/ci/workflows/python-ci.yml")
  commit_message      = "Update reusable Python CI workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}

# Distribute the thin caller workflow to each Python repository.
resource "github_repository_file" "python_ci_caller" {
  for_each = local.python_ci_repos

  depends_on = [github_repository_file.reusable_python_ci]

  repository = each.key
  branch     = "main"
  file       = ".github/workflows/python-ci.yml"
  content = templatefile("${path.module}/ci/templates/python-ci-caller.yml.tftpl", {
    working_directory = each.value.working_directory
  })
  commit_message      = "Add Python CI caller workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}

# =========================================
# HCP Terraform
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
# the import blocks at the end of this file) rather than created fresh. HCP Terraform never returns a
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

# =========================================
# Imports
# =========================================
# 取り込み済みのものも含め、import ブロックはこのファイルの末尾にまとめる。
# apply 後の import は no-op だが、どの資源をどの ID で取り込んだかの記録として残す。
# moved / removed ブロックは記録として残さない。apply 済みになったら消す。

# =========================================
# 2025 GitHub Repositories Imports
# =========================================

import {
  to = module.generate-dev-io-summary.github_repository.this
  id = "generate-dev-io-summary"
}

import {
  to = module.deploy-hcp-vault-dedicated-with-terraform.github_repository.this
  id = "deploy-hcp-vault-dedicated-with-terraform"
}

import {
  to = module.aws-custom-lambda-config-rules.github_repository.this
  id = "aws-custom-lambda-config-rules"
}

import {
  to = module.terraform-aws-budget-slack-notifier.github_repository.this
  id = "terraform-aws-budget-slack-notifier"
}

import {
  to = module.aws-cost-allocation-tags.github_repository.this
  id = "aws-cost-allocation-tags"
}

import {
  to = module.iam-access-analyzer-policy-generate.github_repository.this
  id = "iam-access-analyzer-policy-generate"
}

import {
  to = module.bedrock-slack-ai-agent.github_repository.this
  id = "bedrock-slack-ai-agent"
}

import {
  to = module.docker-simple-cicd-demo.github_repository.this
  id = "docker-simple-cicd-demo"
}

import {
  to = module.github-actions-test.github_repository.this
  id = "github-actions-test"
}

import {
  to = module.github-actions-test-react-demo.github_repository.this
  id = "github-actions-test-react-demo"
}

import {
  to = module.github-actions-test-lint-test-deploy-build.github_repository.this
  id = "github-actions-test-lint-test-deploy-build"
}

import {
  to = module.devcontainer-templates.github_repository.this
  id = "devcontainer-templates"
}

import {
  to = module.github-actions-test-events-deep-dive.github_repository.this
  id = "github-actions-test-events-deep-dive"
}

import {
  to = module.github-actions-test-jobs-artifacts-outputs.github_repository.this
  id = "github-actions-test-jobs-artifacts-outputs"
}

import {
  to = module.haruka-aibara.github_repository.this
  id = "works"
}

# =========================================
# 2025 HCP Terraform Workspaces Imports
# =========================================

import {
  to = tfe_workspace.aws-cost-allocation-tags
  id = "haruka-aibara/aws-cost-allocation-tags"
}

import {
  to = tfe_workspace.bedrock-slack-ai-agent
  id = "haruka-aibara/bedrock-slack-ai-agent"
}

import {
  to = tfe_workspace.deploy-hcp-vault-dedicated-with-terraform
  id = "haruka-aibara/deploy-hcp-vault-dedicated-with-terraform"
}

import {
  to = tfe_workspace.generate-dev-io-summary
  id = "haruka-aibara/generate-dev-io-summary"
}

import {
  to = tfe_workspace.works
  id = "haruka-aibara/works"
}

import {
  to = tfe_workspace.iam-access-analyzer-policy-generate
  id = "haruka-aibara/iam-access-analyzer-policy-generate"
}

import {
  to = tfe_workspace.terraform-aws-budget-slack-notifier
  id = "haruka-aibara/terraform-aws-budget-slack-notifier"
}

# =========================================
# 2026 bedrock-slack-ai-chatbot state 統合
# =========================================
# 旧 bedrock-slack-ai-chatbot ワークスペースの state pull 結果(2026-09-21 取得)から
# 実リソース ID を採った import。手順は
# docs/runbooks/bedrock-slack-ai-chatbot-state-merge.md 参照。

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_function.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_function.slack_bolt_app_bedrock_backend
  id = "bedrock-slack-ai-chatbot_bedrock-backend"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_layer_version.slack_ai_chatbot
  id = "arn:aws:lambda:ap-northeast-1:172580074565:layer:bedrock-slack-ai-chatbot:6"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_layer_version.bedrock
  id = "arn:aws:lambda:ap-northeast-1:172580074565:layer:bedrock-slack-ai-chatbot_bedrock-backend:2"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_event_source_mapping.bedrock
  id = "08b1998b-be2e-4e4d-873b-a679b471a16b"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_lambda_permission.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot/AllowExecutionFromAPIGateway"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot_role"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role.bedrock_backend
  id = "bedrock-slack-ai-chatbot_bedrock-backend-role"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_policy.slack_ai_chatbot
  id = "arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_policy.bedrock_backend
  id = "arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_bedrock-backend-policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role_policy_attachment.slack_ai_chatbot
  id = "bedrock-slack-ai-chatbot_role/arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_iam_role_policy_attachment.lambda_bedrock_backend
  id = "bedrock-slack-ai-chatbot_bedrock-backend-role/arn:aws:iam::172580074565:policy/bedrock-slack-ai-chatbot_bedrock-backend-policy"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_dynamodb_table.idempotency
  id = "bedrock-slack-ai-chatbot-idempotency"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_sqs_queue.slack_ai_chatbot
  id = "https://sqs.ap-northeast-1.amazonaws.com/172580074565/bedrock-slack-ai-chatbot-queue"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_sqs_queue.slack_ai_chatbot_dlq
  id = "https://sqs.ap-northeast-1.amazonaws.com/172580074565/bedrock-slack-ai-chatbot-dead-letter-queue"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_sqs_queue_redrive_allow_policy.slack_ai_chatbot_redrive_allow_policy
  id = "https://sqs.ap-northeast-1.amazonaws.com/172580074565/bedrock-slack-ai-chatbot-dead-letter-queue"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_api.slack_ai_chatbot
  id = "axk7nbk59l"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_integration.slack_ai_chatbot
  id = "axk7nbk59l/nd3bf2d"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_route.slack_ai_chatbot
  id = "axk7nbk59l/uh41xxo"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_apigatewayv2_stage.slack_ai_chatbot
  id = "axk7nbk59l/$default"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_bedrock_inference_profile.claude_opus_4_6
  id = "fwye7uon4qq0"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_cloudwatch_log_group.slack_ai_chatbot
  id = "/aws/lambda/bedrock-slack-ai-chatbot"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_cloudwatch_log_group.bedrock_backend
  id = "/aws/lambda/bedrock-slack-ai-chatbot_bedrock-backend"
}

import {
  to = module.bedrock_slack_ai_chatbot_infra.aws_cloudwatch_log_group.api_gateway
  id = "/aws/apigateway/bedrock-slack-ai-chatbot"
}

# apply が "Key has already been taken" で失敗した2件。works の PR がマージされる
# 前に、Phase B の手順に沿って UI で手動作成されていたため、新規作成ではなく
# 既存アダプトが必要だった。
import {
  to = tfe_variable.bedrock_slack_ai_chatbot_slack_bot_token
  id = "haruka-aibara/works/var-fkaEBQ2HRia4ZZNy"
}

import {
  to = tfe_variable.bedrock_slack_ai_chatbot_slack_signing_secret
  id = "haruka-aibara/works/var-aJ6VhgiSG2jfRoFH"
}
