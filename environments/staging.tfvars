# Production-like edge (WAF, access logs) on cheaper networking: two AZs, one NAT.
aws_region   = "us-east-1"
project_name = "starter-kit"
environment  = "staging"

az_count                = 2
nat_gateway_mode        = "single"
enable_ssm_endpoints    = false
flow_log_retention_days = 30

instance_type          = "t3.small"
asg_min_size           = 2
asg_max_size           = 4
asg_desired_capacity   = 2
cpu_target_utilization = 50

certificate_arn = ""

enable_waf                    = true
enable_alb_access_logs        = true
alb_access_log_retention_days = 30
enable_deletion_protection    = false
s3_force_destroy              = true
alarm_email                   = ""
