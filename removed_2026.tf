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
