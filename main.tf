# ─────────────────────────────────────────────
# Data Sources
# ─────────────────────────────────────────────
data "aws_caller_identity" "current" {}

# ─────────────────────────────────────────────
# VPC Module
# ─────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# ─────────────────────────────────────────────
# EC2 Module
# ─────────────────────────────────────────────
module "ec2" {
  source = "./modules/ec2"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnet_ids[0]
  instance_type    = var.instance_type
  ami_id           = var.ami_id
  key_pair_name    = var.key_pair_name
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

# ─────────────────────────────────────────────
# S3 Module
# ─────────────────────────────────────────────
module "s3" {
  source = "./modules/s3"

  project_name      = var.project_name
  environment       = var.environment
  bucket_name       = var.s3_bucket_name
  versioning_enabled = var.s3_versioning_enabled
  force_destroy     = var.s3_force_destroy
  account_id        = data.aws_caller_identity.current.account_id
}
