data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  name       = "${var.project_name}-${var.environment}"
  azs        = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
}

# Warns (does not block) when private instances would have no route to Systems Manager.
check "private_egress" {
  assert {
    condition     = var.nat_gateway_mode != "none" || var.enable_ssm_endpoints
    error_message = "nat_gateway_mode is \"none\" and enable_ssm_endpoints is false: instances cannot reach Systems Manager, so you will have no shell access."
  }
}

# Warns (does not block) so prod can be stood up before a certificate exists.
check "prod_https" {
  assert {
    condition     = var.environment != "prod" || var.certificate_arn != ""
    error_message = "prod has no certificate_arn, so it serves plain HTTP. Set an ACM certificate to enable HTTPS and the HTTP-to-HTTPS redirect."
  }
}

module "kms" {
  source = "./modules/kms"

  name       = local.name
  account_id = local.account_id
  partition  = local.partition
  region     = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"

  name                    = local.name
  region                  = var.aws_region
  account_id              = local.account_id
  partition               = local.partition
  vpc_cidr                = var.vpc_cidr
  azs                     = local.azs
  nat_gateway_mode        = var.nat_gateway_mode
  enable_ssm_endpoints    = var.enable_ssm_endpoints
  flow_log_retention_days = var.flow_log_retention_days
  kms_key_arn             = module.kms.key_arn
}

module "s3" {
  source = "./modules/s3"

  bucket_name   = "${local.name}-data-${local.account_id}"
  kms_key_arn   = module.kms.key_arn
  force_destroy = var.s3_force_destroy
}

module "alb" {
  source = "./modules/alb"

  name                       = local.name
  account_id                 = local.account_id
  partition                  = local.partition
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr                   = module.vpc.vpc_cidr
  public_subnet_ids          = module.vpc.public_subnet_ids
  ingress_cidrs              = var.alb_ingress_cidrs
  certificate_arn            = var.certificate_arn
  enable_deletion_protection = var.enable_deletion_protection
  enable_access_logs         = var.enable_alb_access_logs
  access_log_retention_days  = var.alb_access_log_retention_days
  access_logs_force_destroy  = var.s3_force_destroy
}

module "waf" {
  source = "./modules/waf"
  count  = var.enable_waf ? 1 : 0

  name               = local.name
  resource_arn       = module.alb.arn
  rate_limit         = var.waf_rate_limit
  kms_key_arn        = module.kms.key_arn
  log_retention_days = var.flow_log_retention_days
  account_id         = local.account_id
  region             = var.aws_region
  partition          = local.partition
}

module "ec2" {
  source = "./modules/ec2"

  name                   = local.name
  partition              = local.partition
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  alb_security_group_id  = module.alb.security_group_id
  target_group_arn       = module.alb.target_group_arn
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  min_size               = var.asg_min_size
  max_size               = var.asg_max_size
  desired_capacity       = var.asg_desired_capacity
  cpu_target_utilization = var.cpu_target_utilization
  data_bucket_arn        = module.s3.bucket_arn
  kms_key_arn            = module.kms.key_arn
}

module "monitoring" {
  source = "./modules/monitoring"

  name                    = local.name
  region                  = var.aws_region
  kms_key_arn             = module.kms.key_arn
  alarm_email             = var.alarm_email
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  asg_name                = module.ec2.asg_name
  waf_web_acl_name        = try(module.waf[0].web_acl_name, null)
}
