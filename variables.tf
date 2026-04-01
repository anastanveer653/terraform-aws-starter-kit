# ─────────────────────────────────────────────
# General
# ─────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for all resources"
  type        = string
  default     = "my-project"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# ─────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ─────────────────────────────────────────────
# EC2
# ─────────────────────────────────────────────
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (default: Amazon Linux 2023 in us-east-1)"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 Key Pair for SSH access (leave empty to skip)"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into the bastion instance"
  type        = string
  default     = "0.0.0.0/0" # Restrict this to your IP in production!
}

# ─────────────────────────────────────────────
# S3
# ─────────────────────────────────────────────
variable "s3_bucket_name" {
  description = "Globally unique name for the S3 bucket (leave empty to auto-generate)"
  type        = string
  default     = ""
}

variable "s3_versioning_enabled" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_force_destroy" {
  description = "Allow Terraform to destroy the bucket even if it contains objects"
  type        = bool
  default     = false
}
