# =========================================
# for personal use only
# =========================================

# Personal Profile Repository
module "haruka-aibara" {
  source = "./modules/repository"

  repository_name = "haruka-aibara"
  description     = "Personal profile repository"

  topics = ["profile"]
}

# Private
module "private" {
  source = "./modules/repository"

  repository_name = "private"
  description     = "private"
  visibility      = "private"
  has_wiki        = false
}

# =========================================
# My Learning Repositories
# =========================================

# All-Round Learning Repository
module "all-round-learning" {
  source = "./modules/repository"

  repository_name = "all-round-learning"
  description     = "A repository for documenting everything I learn"

  topics = ["learning", "documentation"]
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

# Single-turn Bedrock Chatbot
module "bedrock-slack-ai-chatbot" {
  source = "./modules/repository"

  repository_name = "bedrock-slack-ai-chatbot"
  description     = "A Slack AI chatbot application using Amazon Bedrock for single question-and-answer format without continuous conversation history"

  topics = ["aws", "bedrock", "slack", "ai", "chatbot"]
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
