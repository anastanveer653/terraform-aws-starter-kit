variable "name" {
  description = "Name prefix. Must be 28 characters or fewer, since AWS limits load balancer names to 32."
  type        = string

  validation {
    condition     = length(var.name) <= 28
    error_message = "name must be 28 characters or fewer."
  }
}

variable "vpc_id" {
  description = "VPC to create the load balancer in."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR the load balancer may send traffic to."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets for the load balancer, at least two AZs."
  type        = list(string)
}

variable "ingress_cidrs" {
  description = "CIDR blocks allowed to reach the load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "certificate_arn" {
  description = "ACM certificate ARN. Empty means HTTP only."
  type        = string
  default     = ""
}

variable "health_check_path" {
  description = "Path the target group polls on each instance."
  type        = string
  default     = "/health"
}

variable "enable_deletion_protection" {
  description = "Protect the load balancer from deletion."
  type        = bool
  default     = false
}

variable "account_id" {
  description = "AWS account ID, used to name the access log bucket and scope its policy."
  type        = string
}

variable "partition" {
  description = "AWS partition, e.g. aws."
  type        = string
  default     = "aws"
}

variable "enable_access_logs" {
  description = "Write ALB access logs to a dedicated S3 bucket."
  type        = bool
  default     = false
}

variable "access_log_retention_days" {
  description = "Days to keep ALB access logs."
  type        = number
  default     = 90

  validation {
    condition     = var.access_log_retention_days >= 1
    error_message = "access_log_retention_days must be at least 1."
  }
}

variable "access_logs_force_destroy" {
  description = "Allow terraform destroy to delete the access log bucket while it still holds logs."
  type        = bool
  default     = false
}
