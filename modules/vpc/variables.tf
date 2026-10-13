variable "name" {
  description = "Name prefix for all VPC resources."
  type        = string
}

variable "region" {
  description = "AWS region, used to build VPC endpoint service names."
  type        = string
}

variable "account_id" {
  description = "AWS account ID, used to scope the flow log role's trust policy."
  type        = string
}

variable "partition" {
  description = "AWS partition, e.g. aws."
  type        = string
  default     = "aws"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to create one public and one private subnet in."
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "nat_gateway_mode" {
  description = "none, single or per_az."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be one of: none, single, per_az."
  }
}

variable "enable_ssm_endpoints" {
  description = "Create ssm, ssmmessages and ec2messages interface endpoints."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Days to keep VPC flow logs."
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "KMS key used to encrypt the flow log group."
  type        = string
}
