locals {
  enable_https = var.certificate_arn != ""
  app_port     = 80

  access_logs_bucket     = "${var.name}-alb-logs-${var.account_id}"
  access_logs_bucket_arn = "arn:${var.partition}:s3:::${local.access_logs_bucket}"
  access_logs_prefix     = "alb"
}

# ─────────────────────────────────────────────
# Security group
# ─────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Internet-facing load balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  for_each = toset(var.ingress_cidrs)

  security_group_id = aws_security_group.alb.id
  description       = "HTTP from ${each.value}"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  for_each = local.enable_https ? toset(var.ingress_cidrs) : toset([])

  security_group_id = aws_security_group.alb.id
  description       = "HTTPS from ${each.value}"
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "to_targets" {
  security_group_id = aws_security_group.alb.id
  description       = "To application instances inside the VPC"
  cidr_ipv4         = var.vpc_cidr
  ip_protocol       = "tcp"
  from_port         = local.app_port
  to_port           = local.app_port
}

# ─────────────────────────────────────────────
# Access logs (optional)
# ─────────────────────────────────────────────
# Elastic Load Balancing delivers logs from a regional AWS account in older regions
# and from a service principal in newer ones. Granting both works everywhere.
data "aws_elb_service_account" "this" {
  count = var.enable_access_logs ? 1 : 0
}

data "aws_iam_policy_document" "access_logs" {
  count = var.enable_access_logs ? 1 : 0

  statement {
    sid       = "AllowElbAccountLogDelivery"
    actions   = ["s3:PutObject"]
    resources = ["${local.access_logs_bucket_arn}/${local.access_logs_prefix}/AWSLogs/${var.account_id}/*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this[0].arn]
    }
  }

  statement {
    sid       = "AllowElbServiceLogDelivery"
    actions   = ["s3:PutObject"]
    resources = ["${local.access_logs_bucket_arn}/${local.access_logs_prefix}/AWSLogs/${var.account_id}/*"]

    principals {
      type        = "Service"
      identifiers = ["logdelivery.elasticloadbalancing.amazonaws.com"]
    }
  }
}

# ALB access logs support only SSE-S3, so this bucket gets no KMS key.
module "access_logs_bucket" {
  source = "../s3"
  count  = var.enable_access_logs ? 1 : 0

  bucket_name                        = local.access_logs_bucket
  kms_key_arn                        = null
  force_destroy                      = var.access_logs_force_destroy
  policy_documents                   = [data.aws_iam_policy_document.access_logs[0].json]
  archive_noncurrent_versions        = false
  expiration_days                    = var.access_log_retention_days
  noncurrent_version_expiration_days = 7
}

# ─────────────────────────────────────────────
# Load balancer
# ─────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  # Accepted risk: this is the public entry point. Narrow access with var.ingress_cidrs.
  #trivy:ignore:AWS-0053
  internal                   = false
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.public_subnet_ids
  drop_invalid_header_fields = true
  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []

    content {
      bucket  = module.access_logs_bucket[0].bucket_id
      prefix  = local.access_logs_prefix
      enabled = true
    }
  }

  tags = {
    Name = "${var.name}-alb"
  }

  # The bucket policy must exist before the ALB checks it can write there.
  depends_on = [module.access_logs_bucket]
}

# name_prefix with create_before_destroy lets a replacement target group take over
# the listener before the old one is deleted, instead of failing with ResourceInUse.
resource "aws_lb_target_group" "app" {
  name_prefix          = "app-"
  port                 = local.app_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 30

  health_check {
    path                = var.health_check_path
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.name}-tg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ─────────────────────────────────────────────
# Listeners
# ─────────────────────────────────────────────
# Accepted risk: HTTP only forwards when no certificate is set; with one it redirects to HTTPS.
#trivy:ignore:AWS-0054
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  dynamic "default_action" {
    for_each = local.enable_https ? [] : [1]

    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }
  }

  dynamic "default_action" {
    for_each = local.enable_https ? [1] : []

    content {
      type = "redirect"

      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count = local.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
