variable "repository_name" {
  description = "The name of the repository"
  type        = string
}

variable "description" {
  description = "A description of the repository"
  type        = string
  default     = ""
}

variable "visibility" {
  description = "The visibility of the repository. Can be public or private"
  type        = string
  default     = "public"
}

variable "auto_init" {
  description = "Whether to create an initial commit with empty README"
  type        = bool
  default     = true
}

variable "has_issues" {
  description = "Whether to enable GitHub Issues on the repository"
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Whether to enable GitHub Wiki on the repository"
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Whether to enable GitHub Projects on the repository"
  type        = bool
  default     = true
}

variable "has_downloads" {
  description = "Whether to enable GitHub Downloads on the repository"
  type        = bool
  default     = true
}

variable "allow_merge_commit" {
  description = "Whether to allow merge commits"
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Whether to allow squash merges"
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Whether to allow rebase merges"
  type        = bool
  default     = true
}

variable "delete_branch_on_merge" {
  description = "Whether to delete the branch after merging"
  type        = bool
  default     = true
}

variable "topics" {
  description = "The list of topics of the repository"
  type        = list(string)
  default     = []
}
