resource "aws_sns_topic" "alarms" {
  name              = "${var.name}-alarms"
  kms_master_key_id = var.kms_key_arn
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alarm_email == "" ? 0 : 1

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

locals {
  actions = [aws_sns_topic.alarms.arn]
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.name}-alb-5xx"
  alarm_description   = "The load balancer itself is returning 5xx errors."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "target_5xx" {
  alarm_name          = "${var.name}-target-5xx"
  alarm_description   = "Application instances are returning 5xx errors."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.name}-unhealthy-hosts"
  alarm_description   = "At least one instance is failing load balancer health checks."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "latency_p95" {
  alarm_name          = "${var.name}-latency-p95"
  alarm_description   = "95th percentile response time is above the threshold for 3 of the last 5 minutes."
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetResponseTime"
  extended_statistic  = "p95"
  period              = 60
  evaluation_periods  = 5
  datapoints_to_alarm = 3
  threshold           = var.latency_p95_threshold_seconds
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_high" {
  alarm_name          = "${var.name}-asg-cpu-high"
  alarm_description   = "CPU stays high even after autoscaling; the group may be at max_size."
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.cpu_alarm_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = local.actions
  ok_actions          = local.actions

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
}

# ─────────────────────────────────────────────
# Dashboard
# ─────────────────────────────────────────────
locals {
  alb = ["LoadBalancer", var.alb_arn_suffix]
  tg  = ["LoadBalancer", var.alb_arn_suffix, "TargetGroup", var.target_group_arn_suffix]

  widgets = concat(
    [
      {
        title   = "Requests"
        metrics = [concat(["AWS/ApplicationELB", "RequestCount"], local.alb, [{ stat = "Sum" }])]
      },
      {
        title = "5xx errors"
        metrics = [
          concat(["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count"], local.alb, [{ stat = "Sum", label = "Load balancer" }]),
          concat(["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count"], local.tg, [{ stat = "Sum", label = "Targets" }]),
        ]
      },
      {
        title = "Response time (seconds)"
        metrics = [
          concat(["AWS/ApplicationELB", "TargetResponseTime"], local.tg, [{ stat = "p50", label = "p50" }]),
          concat(["AWS/ApplicationELB", "TargetResponseTime"], local.tg, [{ stat = "p95", label = "p95" }]),
        ]
      },
      {
        title = "Target health"
        metrics = [
          concat(["AWS/ApplicationELB", "HealthyHostCount"], local.tg, [{ stat = "Minimum", label = "Healthy" }]),
          concat(["AWS/ApplicationELB", "UnHealthyHostCount"], local.tg, [{ stat = "Maximum", label = "Unhealthy" }]),
        ]
      },
      {
        title   = "Instance CPU (%)"
        metrics = [["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.asg_name, { stat = "Average" }]]
      },
    ],
    [
      for acl in(var.waf_web_acl_name == null ? [] : [var.waf_web_acl_name]) : {
        title = "WAF requests"
        metrics = [
          ["AWS/WAFV2", "AllowedRequests", "WebACL", acl, "Rule", "ALL", "Region", var.region, { stat = "Sum", label = "Allowed" }],
          ["AWS/WAFV2", "BlockedRequests", "WebACL", acl, "Rule", "ALL", "Region", var.region, { stat = "Sum", label = "Blocked" }],
        ]
      }
    ],
  )
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.name

  dashboard_body = jsonencode({
    widgets = [
      for i, w in local.widgets : {
        type   = "metric"
        x      = (i % 2) * 12
        y      = floor(i / 2) * 6
        width  = 12
        height = 6
        properties = {
          title   = w.title
          metrics = w.metrics
          region  = var.region
          view    = "timeSeries"
          period  = 60
        }
      }
    ]
  })
}
