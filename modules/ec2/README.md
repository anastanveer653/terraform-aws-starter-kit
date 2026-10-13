# EC2 module

Launch template, Auto Scaling Group with CPU target tracking and rolling instance refresh, and the instance IAM role.

- Amazon Linux 2023: pinned with `ami_id`, or tracked through the public SSM parameter.
- IMDSv2 only, encrypted gp3 root volume, ELB health checks.
- Inbound only from the load balancer security group; outbound only 443.
- IAM: Systems Manager core plus read/write on one bucket and one KMS key. No SSH keys.

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
| [aws_autoscaling_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_policy.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy) | resource |
| [aws_iam_instance_profile.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.data_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_launch_template.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.https_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.data_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| alb\_security\_group\_id | Security group of the load balancer; the only allowed source of inbound traffic. | `string` | n/a | yes |
| data\_bucket\_arn | ARN of the only S3 bucket the instances may access. | `string` | n/a | yes |
| desired\_capacity | Initial number of instances. | `number` | n/a | yes |
| kms\_key\_arn | KMS key that encrypts the data bucket. | `string` | n/a | yes |
| max\_size | Maximum number of instances. | `number` | n/a | yes |
| min\_size | Minimum number of instances. | `number` | n/a | yes |
| name | Name prefix for all compute resources. | `string` | n/a | yes |
| private\_subnet\_ids | Private subnets the Auto Scaling Group launches into. | `list(string)` | n/a | yes |
| target\_group\_arn | Target group the instances register with. | `string` | n/a | yes |
| vpc\_id | VPC the instances run in. | `string` | n/a | yes |
| ami\_id | AMI to launch. Pin it so only a deliberate change rolls the instances; null tracks ami\_ssm\_parameter. | `string` | `null` | no |
| ami\_ssm\_parameter | Public SSM parameter that holds the AMI ID to launch when ami\_id is null. | `string` | `"/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"` | no |
| cpu\_target\_utilization | Average CPU percentage the target tracking policy holds. | `number` | `50` | no |
| detailed\_monitoring | Enable 1-minute EC2 metrics (extra cost). | `bool` | `false` | no |
| instance\_type | EC2 instance type. | `string` | `"t3.micro"` | no |
| partition | AWS partition, e.g. aws. | `string` | `"aws"` | no |
| root\_volume\_size | Root EBS volume size in GiB. | `number` | `20` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| ami\_id | AMI the launch template uses. |
| asg\_name | Name of the Auto Scaling Group. |
| iam\_role\_arn | IAM role assumed by the instances. |
| imds\_http\_tokens | Instance metadata token setting; required means IMDSv2 only. |
| launch\_template\_id | ID of the launch template. |
| security\_group\_id | Security group of the application instances. |
<!-- END_TF_DOCS -->
