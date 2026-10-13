# ALB module

Internet-facing Application Load Balancer, target group, listeners and security group, with optional access logs.

- With `certificate_arn` set: HTTPS on 443 with a TLS 1.3 policy, and HTTP redirects to it. Without it, HTTP forwards.
- Invalid headers are dropped; egress is limited to the VPC on the app port.
- The target group uses `name_prefix` and `create_before_destroy`, so replacing it never fails on a listener still in use.
- Access logs go to a dedicated bucket built from the [`s3`](../s3) module (SSE-S3, which is all ALB log delivery supports).

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

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| access\_logs\_bucket | ../s3 | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.to_targets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_elb_service_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.access_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| account\_id | AWS account ID, used to name the access log bucket and scope its policy. | `string` | n/a | yes |
| name | Name prefix. Must be 28 characters or fewer, since AWS limits load balancer names to 32. | `string` | n/a | yes |
| public\_subnet\_ids | Public subnets for the load balancer, at least two AZs. | `list(string)` | n/a | yes |
| vpc\_cidr | VPC CIDR the load balancer may send traffic to. | `string` | n/a | yes |
| vpc\_id | VPC to create the load balancer in. | `string` | n/a | yes |
| access\_log\_retention\_days | Days to keep ALB access logs. | `number` | `90` | no |
| access\_logs\_force\_destroy | Allow terraform destroy to delete the access log bucket while it still holds logs. | `bool` | `false` | no |
| certificate\_arn | ACM certificate ARN. Empty means HTTP only. | `string` | `""` | no |
| enable\_access\_logs | Write ALB access logs to a dedicated S3 bucket. | `bool` | `false` | no |
| enable\_deletion\_protection | Protect the load balancer from deletion. | `bool` | `false` | no |
| health\_check\_path | Path the target group polls on each instance. | `string` | `"/health"` | no |
| ingress\_cidrs | CIDR blocks allowed to reach the load balancer. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| partition | AWS partition, e.g. aws. | `string` | `"aws"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| access\_logs\_bucket | Bucket receiving access logs, or null when access logs are off. |
| alb\_arn\_suffix | ARN suffix used as the LoadBalancer dimension in CloudWatch. |
| arn | ARN of the load balancer, e.g. for a WAF association. |
| dns\_name | Public DNS name of the load balancer. |
| http\_listener\_action | What the HTTP listener does: forward or redirect. |
| https\_enabled | True when an HTTPS listener is configured. |
| security\_group\_id | Security group of the load balancer. |
| target\_group\_arn | ARN of the application target group. |
| target\_group\_arn\_suffix | ARN suffix used as the TargetGroup dimension in CloudWatch. |
| zone\_id | Route 53 hosted zone ID of the load balancer, for alias records. |
<!-- END_TF_DOCS -->
