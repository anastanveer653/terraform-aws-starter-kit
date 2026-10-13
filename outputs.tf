output "app_url" {
  description = "URL of the application load balancer."
  value       = "${module.alb.https_enabled ? "https" : "http"}://${module.alb.dns_name}"
}

output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (load balancer and NAT)."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (application instances)."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_count" {
  description = "Number of NAT Gateways created."
  value       = length(module.vpc.nat_gateway_ids)
}

output "asg_name" {
  description = "Name of the application Auto Scaling Group."
  value       = module.ec2.asg_name
}

output "data_bucket_name" {
  description = "Name of the encrypted application data bucket."
  value       = module.s3.bucket_name
}

output "kms_key_arn" {
  description = "ARN of the customer-managed KMS key."
  value       = module.kms.key_arn
}

output "alarm_topic_arn" {
  description = "SNS topic that receives CloudWatch alarm notifications."
  value       = module.monitoring.topic_arn
}

output "dashboard_url" {
  description = "CloudWatch dashboard for traffic, errors, latency, host health and CPU."
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards/dashboard/${module.monitoring.dashboard_name}"
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF web ACL, or null when WAF is off."
  value       = try(module.waf[0].web_acl_arn, null)
}

output "alb_access_logs_bucket" {
  description = "Bucket receiving load balancer access logs, or null when they are off."
  value       = module.alb.access_logs_bucket
}

output "ami_id" {
  description = "AMI the application instances launch from."
  value       = module.ec2.ami_id
}

output "list_instances_command" {
  description = "Command that lists the running application instances, to open an SSM session on one."
  value       = "aws ec2 describe-instances --region ${var.aws_region} --filters Name=tag:aws:autoscaling:groupName,Values=${module.ec2.asg_name} Name=instance-state-name,Values=running --query 'Reservations[].Instances[].InstanceId' --output text"
}
