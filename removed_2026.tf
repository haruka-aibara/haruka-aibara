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

# bedrock-slack-ai-chatbot the standalone repository was absorbed into this
# monorepo with its history (see docs/runbooks/bedrock-slack-ai-chatbot-state-merge.md)
# and its own AWS infra imported into module.bedrock_slack_ai_chatbot_infra.
# Unlike haruka-aibara-private above, this repository really is meant to go
# away, so it is a plain destroy rather than a `removed` block -- see
# modules/repository/main.tf for the matching prevent_destroy lifecycle note.
#
# tfe_workspace.bedrock-slack-ai-chatbot is on the same path (real destroy,
# not `removed`), but needs force_delete = true recorded in state first --
# see hcp_terraform.tf -- before the block itself can be deleted in a
# follow-up PR.
