variable "name" {
  description = "Name prefix for the web ACL and its log group."
  type        = string
}

variable "resource_arn" {
  description = "ARN of the load balancer to protect."
  type        = string
}

variable "rate_limit" {
  description = "Requests per 5 minutes a single IP may send before it is blocked."
  type        = number
  default     = 2000

  validation {
    condition     = var.rate_limit >= 100 && var.rate_limit <= 2000000000
    error_message = "rate_limit must be between 100 and 2,000,000,000."
  }
}

variable "kms_key_arn" {
  description = "KMS key that encrypts the WAF log group."
  type        = string
}

variable "log_retention_days" {
  description = "Days to keep WAF logs."
  type        = number
  default     = 30
}

variable "account_id" {
  description = "AWS account ID, used to scope the log delivery policy."
  type        = string
}

variable "region" {
  description = "AWS region, used to scope the log delivery policy."
  type        = string
}

variable "partition" {
  description = "AWS partition, e.g. aws."
  type        = string
  default     = "aws"
}
