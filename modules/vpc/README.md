# VPC module

One public and one private subnet per availability zone, an internet gateway, NAT gateways (`none`, `single` or `per_az`), per-AZ private route tables, a free S3 gateway endpoint, optional SSM interface endpoints, and KMS-encrypted flow logs.

Subnets are derived with `cidrsubnet` and keyed by AZ, so adding an AZ never renumbers existing subnets. The default security group is stripped of all rules, and the flow-log role trusts only this account's flow logs.

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
| [aws_cloudwatch_log_group.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_ingress_rule.endpoints_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_iam_policy_document.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_logs_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| account\_id | AWS account ID, used to scope the flow log role's trust policy. | `string` | n/a | yes |
| azs | Availability zones to create one public and one private subnet in. | `list(string)` | n/a | yes |
| kms\_key\_arn | KMS key used to encrypt the flow log group. | `string` | n/a | yes |
| name | Name prefix for all VPC resources. | `string` | n/a | yes |
| region | AWS region, used to build VPC endpoint service names. | `string` | n/a | yes |
| vpc\_cidr | CIDR block for the VPC. | `string` | n/a | yes |
| enable\_ssm\_endpoints | Create ssm, ssmmessages and ec2messages interface endpoints. | `bool` | `false` | no |
| flow\_log\_retention\_days | Days to keep VPC flow logs. | `number` | `30` | no |
| nat\_gateway\_mode | none, single or per\_az. | `string` | `"single"` | no |
| partition | AWS partition, e.g. aws. | `string` | `"aws"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| flow\_log\_group\_name | CloudWatch log group receiving VPC flow logs. |
| nat\_gateway\_ids | NAT Gateway IDs. |
| private\_route\_table\_ids | Private route table IDs, in AZ order. |
| private\_subnet\_ids | Private subnet IDs, in AZ order. |
| public\_subnet\_ids | Public subnet IDs, in AZ order. |
| vpc\_cidr | CIDR block of the VPC. |
| vpc\_id | ID of the VPC. |
<!-- END_TF_DOCS -->
