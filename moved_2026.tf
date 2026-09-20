# =========================================
# 2026 Organization migration
# =========================================

# The meta repository was renamed from "haruka-aibara" to "works" and
# transferred to the organization, which changes the for_each key of its
# Terraform CI caller file.
moved {
  from = github_repository_file.terraform_ci_caller["haruka-aibara"]
  to   = github_repository_file.terraform_ci_caller["works"]
}
