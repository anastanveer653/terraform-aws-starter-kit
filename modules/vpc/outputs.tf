output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs, in AZ order."
  value       = [for az in var.azs : aws_subnet.public[az].id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs, in AZ order."
  value       = [for az in var.azs : aws_subnet.private[az].id]
}

output "private_route_table_ids" {
  description = "Private route table IDs, in AZ order."
  value       = [for az in var.azs : aws_route_table.private[az].id]
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs."
  value       = [for nat in aws_nat_gateway.this : nat.id]
}

output "flow_log_group_name" {
  description = "CloudWatch log group receiving VPC flow logs."
  value       = aws_cloudwatch_log_group.flow_logs.name
}
