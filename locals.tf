locals {
  # HCP Terraform の組織名。tfe_workspace.organization に使う。
  tfe_organization = "haruka-aibara"

  # GitHub の owner 名。provider "github" の owner と vcs_repo.identifier に使う。
  # 移行後は Organization を指す。tfe_organization とは別概念なので分離している。
  github_owner = "haruka-aibara"

  # HCP Terraform 側の VCS 連携（OAuth client）が持つトークンの id。
  # vcs_repo.oauth_token_id に使う。GitHub App 認証（GITHUB_APP_*）とは別物。
  oauth_token_id = data.tfe_oauth_client.this.oauth_token_id
}
