# =========================================
# TFE_TOKEN self-rotation (blue / green)
# =========================================
# This workspace issues its own next TFE_TOKEN. The bootstrap, the short-cycle
# verification and the recovery path are in docs/runbooks/tfe-token-rotation.md.
#
# The chain is:
#
#   a cycle elapses
#     -> time_rotating is re-created on the next plan
#     -> its base timestamp moves to "now"
#     -> the expiry derived from it changes
#     -> the team token, whose description carries that expiry, is re-created
#     -> TFE_TOKEN is written with the new token's value
#
# Nothing in this module changes for a scheduled rotation. time_rotating keeps the
# next rotation time in state and the provider compares it with the clock on
# every plan, so the diff appears on its own and a run is all it takes. Nothing
# announces it either: it is visible only once a plan has run.
#
# Two tokens are held half a cycle apart and a run only ever re-creates the one
# it is NOT authenticating with. Re-creating the token in use would 401 the rest
# of that same apply, and recovering from that means a manual bootstrap.

# The clocks. rfc3339 (the base timestamp) is deliberately not set: without it
# the base is the creation time, so each re-creation moves the whole schedule
# forward. Pinning it would freeze the rotation timestamp, and the tokens would
# then never rotate while time_rotating was replaced on every single apply.
#
# triggers is what makes the serials work: changing one re-creates the clock,
# which re-anchors it at "now". That is the only way to move a clock from a PR,
# and the two clocks are created together, so without it they would rotate on
# the same run and take the token in use with them.
resource "time_rotating" "blue" {
  rotation_minutes = var.rotation_minutes
  triggers         = { serial = tostring(var.blue_serial) }
}

resource "time_rotating" "green" {
  rotation_minutes = var.rotation_minutes
  triggers         = { serial = tostring(var.green_serial) }
}

locals {
  # A token dies once the other colour has taken over (half a cycle) plus a
  # buffer, which is well before the rotation that replaces it. Deriving the
  # lifetime keeps it in step with the cycle -- a constant here would silently
  # stretch it the next time the cycle changes.
  token_lifetime = "${floor(var.rotation_minutes / 2) + var.buffer_minutes}m"

  blue_expires_at  = timeadd(time_rotating.blue.rfc3339, local.token_lifetime)
  green_expires_at = timeadd(time_rotating.green.rfc3339, local.token_lifetime)

  # The current token is the one created most recently. The two are equal on the
  # very first apply and the comparison then picks green, which is why the
  # bootstrap staggers blue.
  current_team_token = (
    timecmp(time_rotating.blue.rfc3339, time_rotating.green.rfc3339) > 0
    ? tfe_team_token.blue.token
    : tfe_team_token.green.token
  )
}

# The tokens hang off the owners team, which every organization has. A team of
# its own -- holding manage_workspaces, manage_vcs_settings and manage_teams and
# nothing else -- is what this should use, but creating one needs an entitlement
# this organization does not have: team management starts at the Essentials
# edition, and a Free organization gets "missing entitlements to create teams".
#
# So the narrowing is the part that is given up. An owners team token can do
# everything an organization owner can, which means the rotation buys an expiry
# and an unattended handover, not a smaller blast radius. What it still beats is
# the user token it replaces: that one belongs to a person and never expires.
#
# On a paid edition, put the team back and point the tokens at it.
data "tfe_team" "owners" {
  name         = "owners"
  organization = var.organization
}

# Team tokens are keyed by description, which is what allows two of them to be
# valid at once: a changed description means a new token rather than an edited
# one. The expiry rides in the description for two reasons -- it is the useful
# thing to see in the token list, and it makes the description change whenever
# anything about the token does, which keeps it unique while both generations
# exist during a replacement.
#
# create_before_destroy is what makes that overlap happen. Without it Terraform
# revokes the old token first, and any apply that re-creates the token it is
# authenticating with dies halfway through. With it the new token exists, and
# TFE_TOKEN points at it, before the old one is revoked at the end of the apply.
resource "tfe_team_token" "blue" {
  team_id     = data.tfe_team.owners.id
  description = "works blue r${var.blue_serial} exp ${local.blue_expires_at}"
  expired_at  = local.blue_expires_at

  lifecycle {
    create_before_destroy = true
  }
}

resource "tfe_team_token" "green" {
  team_id     = data.tfe_team.owners.id
  description = "works green r${var.green_serial} exp ${local.green_expires_at}"
  expired_at  = local.green_expires_at

  lifecycle {
    create_before_destroy = true
  }
}

# The write-back. Unlike the GITHUB_APP_* variables next door, this value does
# live in state: a token this configuration issues cannot be kept out of it.
#
# This resource creates the variable rather than adopting one, so the run that
# creates it cannot also be reading it. The bootstrap therefore hands the first
# token to the workspace through a variable set instead, which a workspace
# variable of the same key always overrides -- see the runbook.
resource "tfe_variable" "tfe_token" {
  workspace_id = var.workspace_id
  key          = "TFE_TOKEN"
  value        = local.current_team_token
  category     = "env"
  sensitive    = true
  # The text still names the pre-module file on purpose: changing it would be an
  # in-place update of the live variable for nothing but a comment.
  description = "Rotated by tfe_token_rotation.tf. Only set by hand to recover a stuck workspace."
}
