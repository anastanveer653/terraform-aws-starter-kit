# ─────────────────────────────────────────────
# General
# ─────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must be a valid AWS region code, e.g. us-east-1."
  }
}

variable "project_name" {
  description = "Short name used as a prefix for every resource. Lowercase letters, digits and hyphens, 3-20 characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,18}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-20 characters of lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Extra tags applied to every resource."
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────
# Network
# ─────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC. Subnets are carved out of it automatically."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && tonumber(split("/", var.vpc_cidr)[1]) <= 20
    error_message = "vpc_cidr must be a valid IPv4 CIDR of /20 or larger."
  }
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 3
    error_message = "az_count must be 2 or 3."
  }
}

variable "nat_gateway_mode" {
  description = "Outbound internet for private subnets: none, single (one shared NAT, cheaper) or per_az (one per AZ, highly available)."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["none", "single", "per_az"], var.nat_gateway_mode)
    error_message = "nat_gateway_mode must be one of: none, single, per_az."
  }
}

variable "enable_ssm_endpoints" {
  description = "Create interface endpoints for Systems Manager so instances can be managed without a NAT Gateway."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Days to keep VPC flow logs and WAF logs in CloudWatch."
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.flow_log_retention_days)
    error_message = "flow_log_retention_days must be a retention period CloudWatch Logs supports, e.g. 7, 14, 30, 90 or 365."
  }
}

# ─────────────────────────────────────────────
# Load balancer
# ─────────────────────────────────────────────
variable "certificate_arn" {
  description = "ACM certificate ARN. When set, the ALB serves HTTPS and redirects HTTP to it."
  type        = string
  default     = ""

  validation {
    condition     = var.certificate_arn == "" || can(regex("^arn:aws[a-z-]*:acm:", var.certificate_arn))
    error_message = "certificate_arn must be empty or an ACM certificate ARN."
  }
}

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = alltrue([for c in var.alb_ingress_cidrs : can(cidrhost(c, 0))])
    error_message = "Every entry in alb_ingress_cidrs must be a valid IPv4 CIDR."
  }
}

variable "enable_deletion_protection" {
  description = "Protect the load balancer from accidental deletion."
  type        = bool
  default     = false
}

variable "enable_alb_access_logs" {
  description = "Write load balancer access logs to a dedicated S3 bucket."
  type        = bool
  default     = false
}

variable "alb_access_log_retention_days" {
  description = "Days to keep load balancer access logs."
  type        = number
  default     = 90

  validation {
    condition     = var.alb_access_log_retention_days >= 1
    error_message = "alb_access_log_retention_days must be at least 1."
  }
}

variable "enable_waf" {
  description = "Put an AWS WAF web ACL (managed rules and a per-IP rate limit) in front of the load balancer."
  type        = bool
  default     = false
}

variable "waf_rate_limit" {
  description = "Requests per 5 minutes a single IP may send before WAF blocks it."
  type        = number
  default     = 2000

  validation {
    condition     = var.waf_rate_limit >= 100 && var.waf_rate_limit <= 2000000000
    error_message = "waf_rate_limit must be between 100 and 2,000,000,000."
  }
}

# ─────────────────────────────────────────────
# Compute
# ─────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type for the application tier."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Pin the instance AMI. Null tracks the latest Amazon Linux 2023, so every new AMI release rolls the instances on the next apply."
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "ami_id must be null or an AMI ID such as ami-0123456789abcdef0."
  }
}

variable "asg_min_size" {
  description = "Minimum number of application instances."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of application instances."
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Initial number of application instances. Autoscaling adjusts it afterwards."
  type        = number
  default     = 1
}

variable "cpu_target_utilization" {
  description = "Average CPU percentage the Auto Scaling Group tries to hold."
  type        = number
  default     = 50

  validation {
    condition     = var.cpu_target_utilization >= 10 && var.cpu_target_utilization <= 90
    error_message = "cpu_target_utilization must be between 10 and 90."
  }
}

# ─────────────────────────────────────────────
# Storage and monitoring
# ─────────────────────────────────────────────
variable "s3_force_destroy" {
  description = "Allow terraform destroy to delete the data bucket even when it contains objects."
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "Email address subscribed to alarm notifications. Leave empty to skip."
  type        = string
  default     = ""
}
