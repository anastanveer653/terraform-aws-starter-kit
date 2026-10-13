# Runs with a mocked AWS provider: no account, no credentials, no cost.
#   terraform init -backend=false && terraform test

mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }

  mock_data "aws_ssm_parameter" {
    defaults = {
      insecure_value = "ami-0123456789abcdef0"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_resource "aws_kms_key" {
    defaults = {
      arn = "arn:aws:kms:us-east-1:123456789012:key/11111111-2222-3333-4444-555555555555"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/mock"
    }
  }

  mock_resource "aws_iam_instance_profile" {
    defaults = {
      arn = "arn:aws:iam::123456789012:instance-profile/mock"
    }
  }

  mock_resource "aws_launch_template" {
    defaults = {
      id             = "lt-0123456789abcdef0"
      latest_version = 1
    }
  }

  mock_resource "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:mock"
    }
  }

  mock_resource "aws_lb" {
    defaults = {
      arn        = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/mock/0123456789abcdef"
      arn_suffix = "app/mock/0123456789abcdef"
      dns_name   = "mock-alb-123.us-east-1.elb.amazonaws.com"
    }
  }

  mock_resource "aws_lb_target_group" {
    defaults = {
      arn        = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/mock/0123456789abcdef"
      arn_suffix = "targetgroup/mock/0123456789abcdef"
    }
  }

  mock_resource "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::mock-bucket"
    }
  }

  mock_data "aws_elb_service_account" {
    defaults = {
      arn = "arn:aws:iam::127311923021:root"
    }
  }

  mock_resource "aws_wafv2_web_acl" {
    defaults = {
      arn = "arn:aws:wafv2:us-east-1:123456789012:regional/webacl/mock/11111111-2222-3333-4444-555555555555"
    }
  }

  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:us-east-1:123456789012:mock"
    }
  }
}

variables {
  project_name = "starter-kit"
  environment  = "dev"
}

# ─────────────────────────────────────────────
# Topology
# ─────────────────────────────────────────────
run "dev_uses_two_azs_and_one_nat" {
  command = plan

  variables {
    az_count         = 2
    nat_gateway_mode = "single"
  }

  assert {
    condition     = length(module.vpc.public_subnet_ids) == 2 && length(module.vpc.private_subnet_ids) == 2
    error_message = "Expected one public and one private subnet in each of 2 AZs."
  }

  assert {
    condition     = output.nat_gateway_count == 1
    error_message = "single mode must create exactly one NAT Gateway."
  }
}

run "prod_gets_a_nat_per_az" {
  command = plan

  variables {
    environment      = "prod"
    az_count         = 3
    nat_gateway_mode = "per_az"
    certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-1234"
  }

  assert {
    condition     = output.nat_gateway_count == 3
    error_message = "per_az mode must create one NAT Gateway per AZ."
  }
}

run "prod_without_certificate_warns" {
  command = plan

  variables {
    environment = "prod"
  }

  expect_failures = [check.prod_https]
}

run "no_nat_warns_without_ssm_endpoints" {
  command = plan

  variables {
    nat_gateway_mode     = "none"
    enable_ssm_endpoints = false
  }

  assert {
    condition     = output.nat_gateway_count == 0
    error_message = "none mode must not create NAT Gateways."
  }

  expect_failures = [check.private_egress]
}

# ─────────────────────────────────────────────
# Security
# ─────────────────────────────────────────────
run "instances_require_imdsv2" {
  command = plan

  assert {
    condition     = module.ec2.imds_http_tokens == "required"
    error_message = "Launch template must enforce IMDSv2."
  }
}

run "data_bucket_blocks_public_access" {
  command = plan

  assert {
    condition     = module.s3.public_access_fully_blocked
    error_message = "All four S3 public access block settings must be on."
  }
}

run "http_only_without_certificate" {
  command = apply

  assert {
    condition     = startswith(output.app_url, "http://")
    error_message = "Without a certificate the app URL must be plain HTTP."
  }

  assert {
    condition     = module.alb.http_listener_action == "forward"
    error_message = "Without a certificate the HTTP listener must forward to the app."
  }
}

run "https_redirect_with_certificate" {
  command = apply

  variables {
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-1234"
  }

  assert {
    condition     = startswith(output.app_url, "https://")
    error_message = "With a certificate the app URL must be HTTPS."
  }

  assert {
    condition     = module.alb.http_listener_action == "redirect"
    error_message = "With a certificate HTTP must redirect to HTTPS."
  }
}

# ─────────────────────────────────────────────
# Edge protection, observability and AMI control
# ─────────────────────────────────────────────
run "waf_off_by_default" {
  command = plan

  assert {
    condition     = output.waf_web_acl_arn == null
    error_message = "WAF must be opt-in."
  }

  assert {
    condition     = output.alb_access_logs_bucket == null
    error_message = "ALB access logs must be opt-in."
  }
}

run "waf_protects_the_load_balancer" {
  command = apply

  variables {
    enable_waf = true
  }

  assert {
    condition     = output.waf_web_acl_arn != null
    error_message = "enable_waf must create a web ACL."
  }

  assert {
    condition     = length(module.monitoring.alarm_names) == 5
    error_message = "Expected five CloudWatch alarms."
  }
}

run "access_logs_get_their_own_bucket" {
  command = plan

  variables {
    enable_alb_access_logs = true
  }

  assert {
    condition     = output.alb_access_logs_bucket == "starter-kit-dev-alb-logs-123456789012"
    error_message = "Access logs must go to a dedicated bucket named after the stack and account."
  }

  assert {
    condition     = output.alb_access_logs_bucket != output.data_bucket_name
    error_message = "Access logs must not share the application data bucket."
  }
}

run "pinned_ami_is_used" {
  command = plan

  variables {
    ami_id = "ami-0aaaaaaaaaaaaaaaa"
  }

  assert {
    condition     = output.ami_id == "ami-0aaaaaaaaaaaaaaaa"
    error_message = "A pinned ami_id must override the SSM lookup."
  }
}

run "unpinned_ami_tracks_ssm" {
  command = plan

  assert {
    condition     = output.ami_id == "ami-0123456789abcdef0"
    error_message = "Without ami_id the AMI must come from the SSM parameter."
  }
}

run "dashboard_is_linked" {
  command = plan

  assert {
    condition     = endswith(output.dashboard_url, "#dashboards/dashboard/starter-kit-dev")
    error_message = "dashboard_url must point at the stack's dashboard."
  }
}

# ─────────────────────────────────────────────
# Input validation
# ─────────────────────────────────────────────
run "rejects_malformed_ami_id" {
  command = plan

  variables {
    ami_id = "ubuntu-latest"
  }

  expect_failures = [var.ami_id]
}

run "rejects_tiny_waf_rate_limit" {
  command = plan

  variables {
    enable_waf     = true
    waf_rate_limit = 5
  }

  expect_failures = [var.waf_rate_limit]
}

run "rejects_unknown_environment" {
  command = plan

  variables {
    environment = "qa"
  }

  expect_failures = [var.environment]
}

run "rejects_unknown_nat_mode" {
  command = plan

  variables {
    nat_gateway_mode = "double"
  }

  expect_failures = [var.nat_gateway_mode]
}

run "rejects_bad_project_name" {
  command = plan

  variables {
    project_name = "My_Project"
  }

  expect_failures = [var.project_name]
}

run "rejects_too_many_azs" {
  command = plan

  variables {
    az_count = 4
  }

  expect_failures = [var.az_count]
}
