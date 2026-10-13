output "dns_name" {
  description = "Public DNS name of the load balancer."
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Route 53 hosted zone ID of the load balancer, for alias records."
  value       = aws_lb.this.zone_id
}

output "alb_arn_suffix" {
  description = "ARN suffix used as the LoadBalancer dimension in CloudWatch."
  value       = aws_lb.this.arn_suffix
}

output "target_group_arn" {
  description = "ARN of the application target group."
  value       = aws_lb_target_group.app.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix used as the TargetGroup dimension in CloudWatch."
  value       = aws_lb_target_group.app.arn_suffix
}

output "security_group_id" {
  description = "Security group of the load balancer."
  value       = aws_security_group.alb.id
}

output "https_enabled" {
  description = "True when an HTTPS listener is configured."
  value       = local.enable_https
}

output "http_listener_action" {
  description = "What the HTTP listener does: forward or redirect."
  value       = local.enable_https ? "redirect" : "forward"
}

output "arn" {
  description = "ARN of the load balancer, e.g. for a WAF association."
  value       = aws_lb.this.arn
}

output "access_logs_bucket" {
  description = "Bucket receiving access logs, or null when access logs are off."
  value       = try(module.access_logs_bucket[0].bucket_name, null)
}
