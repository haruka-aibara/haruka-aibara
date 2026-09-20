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

# The workspace was renamed from "haruka-aibara" to "works" in the UI, which is
# the only way it can happen: HCP Terraform refuses a rename while any run is
# still open, and an apply that renamed its own workspace would be exactly that.
moved {
  from = tfe_workspace.haruka-aibara
  to   = tfe_workspace.works
}
