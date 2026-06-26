resource "github_repository" "this" {
  name        = var.repository_name
  description = var.description
  visibility  = var.visibility
  auto_init   = var.auto_init

  has_issues   = var.has_issues
  has_wiki     = var.has_wiki
  has_projects = var.has_projects

  allow_merge_commit     = var.allow_merge_commit
  allow_squash_merge     = var.allow_squash_merge
  allow_rebase_merge     = var.allow_rebase_merge
  delete_branch_on_merge = var.delete_branch_on_merge

  topics = var.topics

  dynamic "security_and_analysis" {
    for_each = var.visibility == "public" ? [1] : []
    content {
      secret_scanning {
        status = "enabled"
      }
      secret_scanning_push_protection {
        status = "enabled"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_repository_vulnerability_alerts" "this" {
  repository = github_repository.this.name
}

resource "github_branch_protection" "this" {
  count = var.enable_branch_protection ? 1 : 0

  repository_id = github_repository.this.node_id
  pattern       = var.protected_branch_pattern

  allows_force_pushes = false
  allows_deletions    = false
  enforce_admins      = var.enforce_admins

  dynamic "required_pull_request_reviews" {
    for_each = var.require_pull_request_reviews ? [1] : []
    content {
      required_approving_review_count = var.required_approving_review_count
      dismiss_stale_reviews           = true
    }
  }
}
