# KMS module

A customer-managed key with automatic rotation and an alias. The key policy lets CloudWatch Logs use it (scoped by encryption context to this account and region) and lets CloudWatch alarms publish to SNS topics encrypted with it (scoped by source account).

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
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy_document.key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| account\_id | AWS account ID that owns the key. | `string` | n/a | yes |
| name | Name prefix for the key and its alias. | `string` | n/a | yes |
| partition | AWS partition, e.g. aws. | `string` | n/a | yes |
| region | Region of the CloudWatch Logs service allowed to use the key. | `string` | n/a | yes |
| deletion\_window\_in\_days | Waiting period before a scheduled key deletion completes. | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| alias\_name | Alias of the KMS key. |
| key\_arn | ARN of the KMS key. |
| key\_id | ID of the KMS key. |
<!-- END_TF_DOCS -->
