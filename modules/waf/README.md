# WAF module

A regional AWS WAF web ACL associated with the load balancer.

| Priority | Rule | Action |
|---|---|---|
| 0 | `AWSManagedRulesAmazonIpReputationList` | Block known-bad IPs |
| 1 | `rate-limit-per-ip` | Block an IP above `rate_limit` requests per 5 minutes |
| 2 | `AWSManagedRulesCommonRuleSet` | OWASP-style common protections |
| 3 | `AWSManagedRulesKnownBadInputsRuleSet` | Log4Shell and other known exploit payloads |

Logs go to a KMS-encrypted CloudWatch log group with the `authorization` and `cookie` headers redacted.

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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [aws_iam_policy_document.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| account\_id | AWS account ID, used to scope the log delivery policy. | `string` | n/a | yes |
| kms\_key\_arn | KMS key that encrypts the WAF log group. | `string` | n/a | yes |
| name | Name prefix for the web ACL and its log group. | `string` | n/a | yes |
| region | AWS region, used to scope the log delivery policy. | `string` | n/a | yes |
| resource\_arn | ARN of the load balancer to protect. | `string` | n/a | yes |
| log\_retention\_days | Days to keep WAF logs. | `number` | `30` | no |
| partition | AWS partition, e.g. aws. | `string` | `"aws"` | no |
| rate\_limit | Requests per 5 minutes a single IP may send before it is blocked. | `number` | `2000` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| log\_group\_name | CloudWatch log group receiving WAF logs. |
| web\_acl\_arn | ARN of the web ACL. |
| web\_acl\_name | Name of the web ACL, the WebACL dimension in CloudWatch. |
<!-- END_TF_DOCS -->
