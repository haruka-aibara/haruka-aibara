# =========================================
# Python CI distribution
# Reusable workflow body + per-repo caller files,
# all managed from this repo as the single source.
# =========================================

# Python repositories that should receive the CI caller workflow.
# Add a line here to onboard a new repo.
locals {
  python_ci_repos = [
    "bedrock-slack-ai-chatbot",
  ]
}

# Push the reusable workflow body into the github-actions repo.
resource "github_repository_file" "reusable_python_ci" {
  repository          = module.github-actions.repository_name
  branch              = "main"
  file                = ".github/workflows/python-ci.yml"
  content             = file("${path.module}/ci/workflows/python-ci.yml")
  commit_message      = "Update reusable Python CI workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}

# Distribute the thin caller workflow to each Python repository.
resource "github_repository_file" "python_ci_caller" {
  for_each = toset(local.python_ci_repos)

  depends_on = [github_repository_file.reusable_python_ci]

  repository          = each.key
  branch              = "main"
  file                = ".github/workflows/python-ci.yml"
  content             = file("${path.module}/ci/templates/python-ci-caller.yml.tftpl")
  commit_message      = "Add Python CI caller workflow (managed by Terraform)"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [commit_author, commit_email]
  }
}
