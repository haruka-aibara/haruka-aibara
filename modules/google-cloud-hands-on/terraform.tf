terraform {
  cloud {
    organization = "haruka-aibara"
    workspaces {
      name = "google-cloud-hands-on"
    }
  }

  required_version = "1.13.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.9.0"
    }
  }
}
