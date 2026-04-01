# ─────────────────────────────────────────────
# VPC Outputs
# ─────────────────────────────────────────────
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# ─────────────────────────────────────────────
# EC2 Outputs
# ─────────────────────────────────────────────
output "ec2_instance_id" {
  description = "ID of the EC2 bastion instance"
  value       = module.ec2.instance_id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_ssh_command" {
  description = "SSH command to connect to the instance"
  value       = module.ec2.ssh_command
}

# ─────────────────────────────────────────────
# S3 Outputs
# ─────────────────────────────────────────────
output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3.bucket_arn
}

output "s3_bucket_regional_domain" {
  description = "Regional domain name of the S3 bucket"
  value       = module.s3.bucket_regional_domain
}
