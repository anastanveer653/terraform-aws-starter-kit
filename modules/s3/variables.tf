variable "project_name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "bucket_name" {
  description = "Override bucket name (leave empty to auto-generate)"
  type        = string
  default     = ""
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket deletion even with objects inside"
  type        = bool
  default     = false
}

variable "account_id" {
  description = "AWS account ID (used for auto-generating unique bucket name)"
  type        = string
}
