output "web_acl_arn" {
  description = "ARN of the web ACL."
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_name" {
  description = "Name of the web ACL, the WebACL dimension in CloudWatch."
  value       = aws_wafv2_web_acl.this.name
}

output "log_group_name" {
  description = "CloudWatch log group receiving WAF logs."
  value       = aws_cloudwatch_log_group.this.name
}
