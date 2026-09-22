variable "organization" {
  type        = string
  description = "HCP Terraform organization that owns the owners team the tokens are issued from."
}

variable "workspace_id" {
  type        = string
  description = "Workspace the current token is written back to as TFE_TOKEN."
}

# nullable = false lets the root pass its UI-overridable variables straight
# through: an unset root variable arrives as null and falls back to the default.
variable "rotation_minutes" {
  type        = number
  nullable    = false
  description = "Length of one rotation cycle. Each colour hands over to the other at half of this, so a run has to happen at least that often."
  default     = 230400 # 160 days. 1 day = 1440, 30 days = 43200.

  validation {
    condition     = var.rotation_minutes >= 20
    error_message = "The cycle has to leave room to start the handover run: keep it at 20 minutes or more."
  }
}

variable "buffer_minutes" {
  type        = number
  nullable    = false
  description = "How long a token stays valid after the handover that stopped using it. It is also the grace period for a late run: miss it and every token has expired."
  default     = 4320 # 3 days, which assumes runs happen at least that often.

  validation {
    condition     = var.buffer_minutes > 0 && var.buffer_minutes < var.rotation_minutes / 2
    error_message = "The buffer has to be positive and shorter than half a cycle, or a token outlives the rotation meant to replace it."
  }
}

# Bumping a serial restarts that colour's cycle now instead of at the next
# rotation: the stagger step of the bootstrap, and an unplanned rotation after a
# leak. Only ever bump the colour that is NOT in use -- a run cannot re-create
# the token it is authenticating with.
variable "blue_serial" {
  type        = number
  description = "Bump to rotate the blue token now."
  default     = 1
}

variable "green_serial" {
  type        = number
  description = "Bump to rotate the green token now."
  default     = 1
}
