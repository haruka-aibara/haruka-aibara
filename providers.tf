# https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  owner = local.github_owner
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
