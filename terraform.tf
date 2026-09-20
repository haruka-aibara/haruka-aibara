terraform {
  cloud {
    organization = "haruka-aibara"
    workspaces {
      name = "haruka-aibara"
    }
  }

  # The workspace resolves its Terraform version from the terraform_version
  # constraint on tfe_workspace.haruka-aibara, which this configuration itself
  # manages. An exact pin here therefore fails every speculative plan until that
  # upgrade has been applied, so keep a minimum-version constraint instead.
  required_version = ">= 1.15.8"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.81"
    }
  }
}
