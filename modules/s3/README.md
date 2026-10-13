# S3 module

A hardened bucket: ACLs disabled, public access fully blocked, versioning, default encryption, lifecycle rules, and a policy that denies plain HTTP and TLS below 1.2.

Encryption is SSE-KMS when `kms_key_arn` is set and SSE-S3 otherwise. Extra policy statements can be merged in through `policy_documents`, which is how the ALB module grants log delivery.

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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| bucket\_name | Globally unique bucket name. | `string` | n/a | yes |
| archive\_noncurrent\_versions | Move old object versions to STANDARD\_IA after 30 days and GLACIER after 90. | `bool` | `true` | no |
| expiration\_days | Days after which current objects expire. Null keeps them forever. | `number` | `null` | no |
| force\_destroy | Allow destroying the bucket while it still contains objects. | `bool` | `false` | no |
| kms\_key\_arn | KMS key for default bucket encryption. Null falls back to SSE-S3, for services that cannot write with a customer-managed key. | `string` | `null` | no |
| noncurrent\_version\_expiration\_days | Days after which old object versions are permanently deleted. | `number` | `365` | no |
| policy\_documents | Extra IAM policy documents (JSON) merged into the bucket policy, e.g. to let a service write to it. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| bucket\_arn | ARN of the bucket. |
| bucket\_id | ID of the bucket. |
| bucket\_name | Name of the bucket. |
| public\_access\_fully\_blocked | True when all four public access block settings are on. |
<!-- END_TF_DOCS -->
