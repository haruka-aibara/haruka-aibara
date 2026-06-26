# =========================================
# Terraform CI distribution
# Reusable workflow body + per-repo caller files,
# all managed from this repo as the single source.
# =========================================

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
