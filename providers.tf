# https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  owner = local.github_owner
  # See docs/reference/github-authentication.md for what these are.
  # Authentication comes from the GITHUB_APP_ID / GITHUB_APP_INSTALLATION_ID /
  # GITHUB_APP_PEM_FILE environment variables on HCP Terraform, declared in
  # workspace_variables.tf. The provider reads the GITHUB_APP_ prefix without an
  # app_auth block and mints a one-hour installation token per run.
}

# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs
provider "tfe" {
  # TFE_TOKEN is already set as an environment variable on HCP Terraform Cloud
  # organization is set per resource
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
# For the bedrock-slack-ai-chatbot module. Authenticates via HCP Terraform's
# dynamic provider credentials (OIDC) instead of static keys: the
# TFC_AWS_PROVIDER_AUTH / TFC_AWS_RUN_ROLE_ARN workspace variables are set in
# the UI (they aren't secrets themselves, but the AWS-side IAM OIDC provider
# and role they point at were set up by hand, so there's nothing to import
# here).
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = local.bedrock_slack_ai_chatbot_default_tags
  }
}
