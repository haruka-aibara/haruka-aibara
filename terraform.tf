terraform {
  cloud {
    organization = "haruka-aibara"
    workspaces {
      name = "haruka-aibara"
    }
  }

  required_version = "1.15.7"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.78"
    }
  }
}
