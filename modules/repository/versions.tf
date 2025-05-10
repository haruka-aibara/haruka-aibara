# To Avoid warning when `terraform init`
# │ Warning: Additional provider information from registry
# │ 
# │ The remote registry returned warnings for registry.terraform.io/hashicorp/github:
# │ - For users on Terraform 0.13 or greater, this provider has moved to integrations/github. Please update your
# │ source in required_providers.
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6" # 2025-05-10 latest
    }
  }
}
