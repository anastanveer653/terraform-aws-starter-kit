output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.main.private_ip
}

output "security_group_id" {
  description = "Security group ID attached to the instance"
  value       = aws_security_group.bastion.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to the instance"
  value       = aws_iam_role.ec2_role.arn
}

output "ssh_command" {
  description = "SSH command to connect (requires key pair)"
  value       = "ssh -i ~/.ssh/${var.key_pair_name}.pem ec2-user@${aws_instance.main.public_ip}"
}
