output "topic_arn" {
  description = "ARN of the alarm SNS topic."
  value       = aws_sns_topic.alarms.arn
}

output "alarm_names" {
  description = "Names of all CloudWatch alarms."
  value = [
    aws_cloudwatch_metric_alarm.alb_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.target_5xx.alarm_name,
    aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name,
    aws_cloudwatch_metric_alarm.latency_p95.alarm_name,
    aws_cloudwatch_metric_alarm.asg_cpu_high.alarm_name,
  ]
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard."
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}
