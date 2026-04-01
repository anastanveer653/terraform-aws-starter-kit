# ─────────────────────────────────────────────
# Security Group — Bastion Host
# ─────────────────────────────────────────────
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-${var.environment}-bastion-sg"
  description = "Security group for bastion/web EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # HTTP (uncomment for web servers)
  # ingress {
  #   description = "HTTP"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # HTTPS (uncomment for web servers)
  # ingress {
  #   description = "HTTPS"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion-sg"
  }
}

# ─────────────────────────────────────────────
# IAM Role for EC2 (SSM + S3 read access)
# ─────────────────────────────────────────────
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ─────────────────────────────────────────────
# EC2 Instance
# ─────────────────────────────────────────────
resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_pair_name != "" ? var.key_pair_name : null

  # Encrypted root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-${var.environment}-root-ebs"
    }
  }

  # User data: basic hardening + tools
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # Update system
    dnf update -y

    # Install useful tools
    dnf install -y \
      aws-cli \
      htop \
      git \
      curl \
      wget \
      unzip

    # Enable and start SSM agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent

    # Disable root SSH login
    sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd

    echo "Bootstrap complete." >> /var/log/user-data.log
  EOF
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 enforced
    http_put_response_hop_limit = 1
  }

  monitoring = true

  tags = {
    Name = "${var.project_name}-${var.environment}-bastion"
  }

  lifecycle {
    ignore_changes = [ami_id, user_data]
  }
}
