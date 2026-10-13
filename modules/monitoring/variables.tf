variable "name" {
  description = "Name prefix for the topic and alarms."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key that encrypts the SNS topic."
  type        = string
}

variable "alarm_email" {
  description = "Email subscribed to the alarm topic. Empty to skip."
  type        = string
  default     = ""

  validation {
    condition     = var.alarm_email == "" || can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alarm_email))
    error_message = "alarm_email must be empty or a valid email address."
  }
}

variable "alb_arn_suffix" {
  description = "Load balancer ARN suffix (CloudWatch dimension)."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "Target group ARN suffix (CloudWatch dimension)."
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name (CloudWatch dimension)."
  type        = string
}

variable "alb_5xx_threshold" {
  description = "5xx responses per 5 minutes that trigger an alarm."
  type        = number
  default     = 10
}

variable "cpu_alarm_threshold" {
  description = "Average CPU percentage over 15 minutes that triggers an alarm."
  type        = number
  default     = 80
}

variable "region" {
  description = "AWS region the dashboard reads metrics from."
  type        = string
}

variable "latency_p95_threshold_seconds" {
  description = "p95 target response time, in seconds, that triggers an alarm."
  type        = number
  default     = 1
}

variable "waf_web_acl_name" {
  description = "Web ACL to chart on the dashboard. Null when WAF is off."
  type        = string
  default     = null
}
