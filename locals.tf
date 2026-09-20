locals {
  # HCP Terraform の組織名。tfe_workspace.organization に使う。
  tfe_organization = "haruka-aibara"

  # GitHub の owner 名。provider "github" の owner と vcs_repo.identifier に使う。
  # 移行後は Organization を指す。tfe_organization とは別概念なので分離している。
  github_owner = "haruka-aibara"

  github_app_installation_id = var.github_app_installation_id
}
