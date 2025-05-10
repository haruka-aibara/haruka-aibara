resource "github_repository" "this" {
  name        = var.repository_name
  description = var.description
  visibility  = var.visibility
  auto_init   = var.auto_init

  has_issues    = var.has_issues
  has_wiki      = var.has_wiki
  has_projects  = var.has_projects
  has_downloads = var.has_downloads

  allow_merge_commit     = var.allow_merge_commit
  allow_squash_merge     = var.allow_squash_merge
  allow_rebase_merge     = var.allow_rebase_merge
  delete_branch_on_merge = var.delete_branch_on_merge

  topics = var.topics

  lifecycle {
    prevent_destroy = true
  }
}
