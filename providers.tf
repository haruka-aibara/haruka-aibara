# https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  owner = "haruka-aibara"
  # GITHUB_TOKEN is already set as an environment variable on HCP Terraform Cloud
}

# https://registry.terraform.io/providers/hashicorp/tfe/latest/docs
provider "tfe" {
  # TFE_TOKEN is already set as an environment variable on HCP Terraform Cloud
  # organization is set per resource
}
