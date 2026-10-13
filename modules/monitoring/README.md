# Monitoring module

An encrypted SNS topic with an optional email subscription, five CloudWatch alarms, and a dashboard.

| Alarm | Fires when |
|---|---|
| `alb-5xx` | The load balancer itself returns 5xx |
| `target-5xx` | Instances return 5xx |
| `unhealthy-hosts` | Any target fails health checks for 3 minutes |
| `latency-p95` | p95 response time stays above the threshold |
| `asg-cpu-high` | CPU stays high even after scaling out |

The dashboard charts requests, errors, p50/p95 latency, target health and CPU, plus WAF allowed/blocked requests when WAF is on.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.11.0 |
| aws | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| aws | >= 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_dashboard.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_metric_alarm.alb_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.asg_cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.latency_p95](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.target_5xx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unhealthy_hosts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic.alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| alb\_arn\_suffix | Load balancer ARN suffix (CloudWatch dimension). | `string` | n/a | yes |
| asg\_name | Auto Scaling Group name (CloudWatch dimension). | `string` | n/a | yes |
| kms\_key\_arn | KMS key that encrypts the SNS topic. | `string` | n/a | yes |
| name | Name prefix for the topic and alarms. | `string` | n/a | yes |
| region | AWS region the dashboard reads metrics from. | `string` | n/a | yes |
| target\_group\_arn\_suffix | Target group ARN suffix (CloudWatch dimension). | `string` | n/a | yes |
| alarm\_email | Email subscribed to the alarm topic. Empty to skip. | `string` | `""` | no |
| alb\_5xx\_threshold | 5xx responses per 5 minutes that trigger an alarm. | `number` | `10` | no |
| cpu\_alarm\_threshold | Average CPU percentage over 15 minutes that triggers an alarm. | `number` | `80` | no |
| latency\_p95\_threshold\_seconds | p95 target response time, in seconds, that triggers an alarm. | `number` | `1` | no |
| waf\_web\_acl\_name | Web ACL to chart on the dashboard. Null when WAF is off. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| alarm\_names | Names of all CloudWatch alarms. |
| dashboard\_name | Name of the CloudWatch dashboard. |
| topic\_arn | ARN of the alarm SNS topic. |
<!-- END_TF_DOCS -->
