output "asg_name" {
  description = "Name of the Auto Scaling Group."
  value       = aws_autoscaling_group.app.name
}

output "launch_template_id" {
  description = "ID of the launch template."
  value       = aws_launch_template.app.id
}

output "security_group_id" {
  description = "Security group of the application instances."
  value       = aws_security_group.app.id
}

output "iam_role_arn" {
  description = "IAM role assumed by the instances."
  value       = aws_iam_role.app.arn
}

output "ami_id" {
  description = "AMI the launch template uses."
  value       = aws_launch_template.app.image_id
}

output "imds_http_tokens" {
  description = "Instance metadata token setting; required means IMDSv2 only."
  value       = aws_launch_template.app.metadata_options[0].http_tokens
}
