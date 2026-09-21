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
# The GitHub repository itself was deleted by hand once the merge was
# confirmed working, so there is nothing left for Terraform to destroy here
# either -- `destroy = false` for the same reason as above.
removed {
  from = module.bedrock-slack-ai-chatbot

  lifecycle {
    destroy = false
  }
}

# The old bedrock-slack-ai-chatbot HCP Terraform workspace's own AWS
# resources are now managed by module.bedrock_slack_ai_chatbot_infra instead
# (imported into this workspace's state). The old workspace was force-deleted
# by hand in the HCP Terraform UI -- a plain destroy here would otherwise
# refuse to run while resources were still listed in its own state -- so
# there is nothing left for Terraform to destroy.
removed {
  from = tfe_workspace.bedrock-slack-ai-chatbot

  lifecycle {
    destroy = false
  }
}
