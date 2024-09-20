# AWS プロバイダーは実装時のメジャーバージョンの最新以上を使用するよう定義
terraform {
  cloud {
    organization = "haruka_aibara"
    workspaces {
      name = "deploy-hcp-vault-dedicated-with-terraform"
    }
  }
}
