# =========================================
# 2026 Removals
# =========================================

# haruka-aibara-private was transferred out of the organization to the personal
# account, because private work is not kept in the organization. The repository
# still exists -- it is only this configuration that stops tracking it, so the
# lifecycle block is what makes this a hand-off rather than a deletion.
#
# Leaving it in place would have been the riskier option. GitHub redirects the
# old owner/name for a while, so a plan stays quiet until it does not, and the
# first read that returns 404 turns into a proposal to create the repository
# again -- inside the organization, which is exactly what the transfer was for.
removed {
  from = module.haruka-aibara-private

  lifecycle {
    destroy = false
  }
}

# bedrock-slack-ai-chatbot the standalone repository, and the HCP Terraform
# workspace that managed its AWS infra, were absorbed into this monorepo
# (see docs/runbooks/bedrock-slack-ai-chatbot-state-merge.md and
# module.bedrock_slack_ai_chatbot_infra). Unlike haruka-aibara-private above,
# both really are meant to go away, so both were plain destroys rather than
# `removed` blocks -- see modules/repository/main.tf's prevent_destroy note
# for the repository, and hcp_terraform.tf's git history for the
# force_delete = true step the workspace needed first.
