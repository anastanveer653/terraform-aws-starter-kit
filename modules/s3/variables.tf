variable "bucket_name" {
  description = "Globally unique bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters of lowercase letters, digits, dots and hyphens."
  }
}

variable "kms_key_arn" {
  description = "KMS key for default bucket encryption. Null falls back to SSE-S3, for services that cannot write with a customer-managed key."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "Allow destroying the bucket while it still contains objects."
  type        = bool
  default     = false
}

variable "policy_documents" {
  description = "Extra IAM policy documents (JSON) merged into the bucket policy, e.g. to let a service write to it."
  type        = list(string)
  default     = []
}

variable "archive_noncurrent_versions" {
  description = "Move old object versions to STANDARD_IA after 30 days and GLACIER after 90."
  type        = bool
  default     = true
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which old object versions are permanently deleted."
  type        = number
  default     = 365

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days must be at least 1."
  }
}

variable "expiration_days" {
  description = "Days after which current objects expire. Null keeps them forever."
  type        = number
  default     = null

  validation {
    condition     = var.expiration_days == null || try(var.expiration_days >= 1, false)
    error_message = "expiration_days must be null or at least 1."
  }
}
