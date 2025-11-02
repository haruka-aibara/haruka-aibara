variable "GOOGLE_CREDENTIALS" {
  type        = string
  description = "Google Cloud credentials"
}

variable "project_id" {
  type        = string
  description = "Google Cloud project ID"
  default     = "LearnGoogleCloud"
}

variable "region" {
  type        = string
  description = "Google Cloud region"
  default     = "asia-northeast1"
}
