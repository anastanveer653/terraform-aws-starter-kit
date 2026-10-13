variable "name" {
  description = "Name prefix for the key and its alias."
  type        = string
}

variable "account_id" {
  description = "AWS account ID that owns the key."
  type        = string
}

variable "partition" {
  description = "AWS partition, e.g. aws."
  type        = string
}

variable "region" {
  description = "Region of the CloudWatch Logs service allowed to use the key."
  type        = string
}

variable "deletion_window_in_days" {
  description = "Waiting period before a scheduled key deletion completes."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}
