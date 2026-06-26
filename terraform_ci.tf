# =========================================
# Terraform CI distribution
# Reusable workflow body + per-repo caller files,
# all managed from this repo as the single source.
# =========================================

# Terraform repositories that should receive the CI caller workflow.
# Add a line here to onboard a new repo.
locals {
  terraform_ci_repos = {
    "aws-cost-allocation-tags"                  = { working_directory = "." }
    "bedrock-slack-ai-agent"                    = { working_directory = "." }
    "bedrock-slack-ai-chatbot"                  = { working_directory = "." }
    "deploy-hcp-vault-dedicated-with-terraform" = { working_directory = "." }
    "generate-dev-io-summary"                   = { working_directory = "." }
    "haruka-aibara"                             = { working_directory = "." }
    "iam-access-analyzer-policy-generate"       = { working_directory = "." }
    "terraform-aws-budget-slack-notifier"       = { working_directory = "." }
    "google-cloud-hands-on"                     = { working_directory = "." }
  }
}

# Push the reusable workflow body into the github-actions repo.
resource "github_repository_file" "reusable_terraform_ci" {
  repository          = module.github-actions.repository_name
  branch              = "main"
  file                = ".github/workflows/terraform-ci.yml"
  content             = file("${path.module}/ci/workflows/terraform-ci.yml")
  commit_message      = "Update reusable Terraform CI workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}

# Distribute the thin caller workflow to each Terraform repository.
resource "github_repository_file" "terraform_ci_caller" {
  for_each = local.terraform_ci_repos

  depends_on = [github_repository_file.reusable_terraform_ci]

  repository = each.key
  branch     = "main"
  file       = ".github/workflows/terraform-ci.yml"
  content = templatefile("${path.module}/ci/templates/terraform-ci-caller.yml.tftpl", {
    working_directory = each.value.working_directory
  })
  commit_message      = "Add Terraform CI caller workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}
