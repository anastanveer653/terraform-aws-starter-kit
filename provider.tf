terraform {
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Partial configuration: supply the rest with
  # terraform init -backend-config=environments/<env>.s3.tfbackend
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.tags, {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Repository  = "github.com/anastanveer653/terraform-aws-starter-kit"
    })
  }
}
