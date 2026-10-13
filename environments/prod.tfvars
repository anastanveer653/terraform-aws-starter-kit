# Highly available: three AZs, a NAT per AZ, at least two instances, WAF and access logs.
aws_region   = "us-east-1"
project_name = "starter-kit"
environment  = "prod"

az_count                = 3
nat_gateway_mode        = "per_az"
enable_ssm_endpoints    = true
flow_log_retention_days = 90

instance_type          = "t3.small"
asg_min_size           = 2
asg_max_size           = 6
asg_desired_capacity   = 2
cpu_target_utilization = 50

# Pin the AMI so a new Amazon Linux release only reaches prod through a reviewed change:
#   aws ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query Parameter.Value --output text
# ami_id = "ami-..."

# Set an ACM certificate to serve HTTPS. Until then, plan warns via check "prod_https".
certificate_arn = ""

enable_waf                    = true
waf_rate_limit                = 2000
enable_alb_access_logs        = true
alb_access_log_retention_days = 365
enable_deletion_protection    = true
s3_force_destroy              = false
alarm_email                   = ""
