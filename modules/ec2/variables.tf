variable "name" {
  description = "Name prefix for all compute resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC the instances run in."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets the Auto Scaling Group launches into."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group of the load balancer; the only allowed source of inbound traffic."
  type        = string
}

variable "target_group_arn" {
  description = "Target group the instances register with."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI to launch. Pin it so only a deliberate change rolls the instances; null tracks ami_ssm_parameter."
  type        = string
  default     = null

  validation {
    condition     = var.ami_id == null || can(regex("^ami-[0-9a-f]{8,17}$", var.ami_id))
    error_message = "ami_id must be null or an AMI ID such as ami-0123456789abcdef0."
  }
}

variable "ami_ssm_parameter" {
  description = "Public SSM parameter that holds the AMI ID to launch when ami_id is null."
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "partition" {
  description = "AWS partition, e.g. aws."
  type        = string
  default     = "aws"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 20
}

variable "detailed_monitoring" {
  description = "Enable 1-minute EC2 metrics (extra cost)."
  type        = bool
  default     = false
}

variable "min_size" {
  description = "Minimum number of instances."
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances."
  type        = number
}

variable "desired_capacity" {
  description = "Initial number of instances."
  type        = number
}

variable "cpu_target_utilization" {
  description = "Average CPU percentage the target tracking policy holds."
  type        = number
  default     = 50
}

variable "data_bucket_arn" {
  description = "ARN of the only S3 bucket the instances may access."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key that encrypts the data bucket."
  type        = string
}
