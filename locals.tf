locals {
  # HCP Terraform の組織名。tfe_workspace.organization に使う。
  tfe_organization = "haruka-aibara"

  # GitHub の owner 名。provider "github" の owner と vcs_repo.identifier に使う。
  # 移行後は Organization を指す。tfe_organization とは別概念なので分離している。
  github_owner = "haruka-aibara"

  # HCP Terraform 側の VCS 連携（OAuth client）が持つトークンの id。
  # vcs_repo.oauth_token_id に使う。GitHub App 認証（GITHUB_APP_*）とは別物。
  oauth_token_id = data.tfe_oauth_client.this.oauth_token_id

  # bedrock-slack-ai-chatbot モジュールの AWS リソースに付与する既定タグ。
  # provider "aws" の default_tags はモジュール単位で分離できないため、この
  # リポジトリが AWS 管理するアプリが増えたら再設計が要る。
  bedrock_slack_ai_chatbot_default_tags = {
    Owner       = "haruka-aibara"
    Terraform   = true
    Environment = "production"
    Project     = "bedrock-slack-ai-chatbot"
    Repository  = "https://github.com/haruka-aibara/works"
  }

  # Terraform repositories that should receive the CI caller workflow.
  # Add a line here to onboard a new repo.
  terraform_ci_repos = {
    "aws-cost-allocation-tags"                  = { working_directory = "." }
    "bedrock-slack-ai-agent"                    = { working_directory = "." }
    "deploy-hcp-vault-dedicated-with-terraform" = { working_directory = "." }
    "generate-dev-io-summary"                   = { working_directory = "." }
    "works"                                     = { working_directory = "." }
    "iam-access-analyzer-policy-generate"       = { working_directory = "." }
    "terraform-aws-budget-slack-notifier"       = { working_directory = "." }
    "google-cloud-hands-on"                     = { working_directory = "." }
  }

  # Python repositories that should receive the CI caller workflow.
  # Add a line here to onboard a new repo.
  python_ci_repos = {
    "works" = { working_directory = "modules/bedrock-slack-ai-chatbot" }
  }
}
