locals {
  app_port = 80
  ami_id   = var.ami_id != null ? var.ami_id : data.aws_ssm_parameter.ami[0].insecure_value
}

# Without a pinned ami_id, track the latest Amazon Linux 2023 AMI. Each new release
# changes the launch template, and the next apply rolls every instance onto it.
data "aws_ssm_parameter" "ami" {
  count = var.ami_id == null ? 1 : 0

  name = var.ami_ssm_parameter
}

# ─────────────────────────────────────────────
# Security group: reachable only from the load balancer
# ─────────────────────────────────────────────
resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "Application instances, reachable only from the load balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.name}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTP from the load balancer only"
  referenced_security_group_id = var.alb_security_group_id
  ip_protocol                  = "tcp"
  from_port                    = local.app_port
  to_port                      = local.app_port
}

# HTTPS out is all the instances need: SSM, package repos and AWS APIs.
resource "aws_vpc_security_group_egress_rule" "https_out" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS to AWS APIs and package repositories"
  # Accepted risk: AWS public endpoints have no fixed CIDR; port is limited to 443.
  #trivy:ignore:AWS-0104
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

# ─────────────────────────────────────────────
# IAM: SSM access plus least-privilege access to one bucket
# ─────────────────────────────────────────────
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "app" {
  name               = "${var.name}-app-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:${var.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "data_bucket" {
  statement {
    sid       = "ListDataBucket"
    actions   = ["s3:ListBucket"]
    resources = [var.data_bucket_arn]
  }

  statement {
    sid       = "ReadWriteDataObjects"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.data_bucket_arn}/*"]
  }

  statement {
    sid       = "UseDataKey"
    actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
    resources = [var.kms_key_arn]
  }
}

resource "aws_iam_role_policy" "data_bucket" {
  name   = "data-bucket-access"
  role   = aws_iam_role.app.id
  policy = data.aws_iam_policy_document.data_bucket.json
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.name}-app-profile"
  role = aws_iam_role.app.name
}

# ─────────────────────────────────────────────
# Launch template
# ─────────────────────────────────────────────
resource "aws_launch_template" "app" {
  name_prefix            = "${var.name}-app-"
  image_id               = local.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app.id]
  update_default_version = true

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    name = var.name
  }))

  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = var.detailed_monitoring
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp3"
      volume_size           = var.root_volume_size
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.name}-app"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.name}-app-root"
    }
  }
}

# ─────────────────────────────────────────────
# Auto Scaling Group
# ─────────────────────────────────────────────
resource "aws_autoscaling_group" "app" {
  name                      = "${var.name}-app-asg"
  vpc_zone_identifier       = var.private_subnet_ids
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  # Changing the launch template replaces instances gradually, not all at once.
  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.name}-app"
    propagate_at_launch = true
  }

  lifecycle {
    precondition {
      condition     = var.min_size <= var.desired_capacity && var.desired_capacity <= var.max_size
      error_message = "Auto Scaling sizes must satisfy min_size <= desired_capacity <= max_size."
    }

    # The scaling policy owns desired_capacity after the first apply.
    ignore_changes = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target_utilization
  }
}
