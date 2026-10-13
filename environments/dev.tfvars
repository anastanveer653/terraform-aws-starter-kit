# Cheapest useful setup: one shared NAT, one small instance, no WAF.
aws_region   = "us-east-1"
project_name = "starter-kit"
environment  = "dev"

az_count                = 2
nat_gateway_mode        = "single"
enable_ssm_endpoints    = false
flow_log_retention_days = 14

instance_type          = "t3.micro"
asg_min_size           = 1
asg_max_size           = 2
asg_desired_capacity   = 1
cpu_target_utilization = 50

enable_waf                 = false
enable_alb_access_logs     = false
enable_deletion_protection = false
s3_force_destroy           = true
alarm_email                = ""
