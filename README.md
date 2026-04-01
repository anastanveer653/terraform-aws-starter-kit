# 🏗️ Terraform AWS Starter Kit

![Terraform](https://img.shields.io/badge/Terraform-≥1.3.0-7B42BC?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-Provider_5.x-FF9900?logo=amazonaws)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Production--Ready-brightgreen)

A modular, production-ready Terraform starter kit that provisions a complete AWS environment including a **VPC**, **EC2 bastion host**, and a **secure S3 bucket** — all following AWS best practices.

---

## 📐 Architecture

```
┌──────────────────────────────────────────────────────┐
│                      AWS VPC                          │
│  CIDR: 10.0.0.0/16                                   │
│                                                       │
│  ┌──────────────────┐   ┌──────────────────┐         │
│  │  Public Subnet   │   │  Public Subnet   │         │
│  │  us-east-1a      │   │  us-east-1b      │         │
│  │  10.0.1.0/24     │   │  10.0.2.0/24     │         │
│  │                  │   │                  │         │
│  │  ┌────────────┐  │   │                  │         │
│  │  │ EC2 Bastion│  │   │                  │         │
│  │  │  (t3.micro)│  │   │                  │         │
│  │  └────────────┘  │   │                  │         │
│  │  ┌────────────┐  │   │                  │         │
│  │  │ NAT Gateway│  │   │                  │         │
│  │  └────────────┘  │   │                  │         │
│  └──────────────────┘   └──────────────────┘         │
│                                                       │
│  ┌──────────────────┐   ┌──────────────────┐         │
│  │  Private Subnet  │   │  Private Subnet  │         │
│  │  us-east-1a      │   │  us-east-1b      │         │
│  │  10.0.11.0/24    │   │  10.0.12.0/24    │         │
│  └──────────────────┘   └──────────────────┘         │
│                                                       │
└──────────────────────────────┬───────────────────────┘
                               │ Internet Gateway
                               ▼
                          🌐 Internet

  ┌──────────────────────────────────┐
  │  S3 Bucket                       │
  │  • AES-256 encryption            │
  │  • Versioning enabled            │
  │  • HTTPS-only bucket policy      │
  │  • Lifecycle rules (Glacier)     │
  └──────────────────────────────────┘
```

---

## ✅ Features

### VPC
- Multi-AZ setup with **public and private subnets**
- **Internet Gateway** for public subnet internet access
- **NAT Gateway** for secure outbound traffic from private subnets
- Separate **route tables** per subnet tier
- Explicit **Network ACL** configuration

### EC2
- Amazon Linux 2023 bastion host in public subnet
- **IMDSv2 enforced** (no v1 metadata endpoint)
- **Encrypted EBS root volume** (gp3)
- **IAM role** with SSM Session Manager + S3 read access (no SSH required)
- Automated user data: system update, hardening, AWS CLI
- Root SSH login disabled by default

### S3
- **All public access blocked**
- **AES-256 server-side encryption**
- **Versioning** enabled
- **HTTPS-only** bucket policy
- **Lifecycle rules**: auto-transition to STANDARD_IA → GLACIER → expiry
- Incomplete multipart upload cleanup

---

## 🗂️ Project Structure

```
terraform-aws-starter-kit/
├── main.tf                    # Root module — calls all child modules
├── provider.tf                # AWS provider & Terraform version config
├── variables.tf               # All input variables with defaults
├── outputs.tf                 # Root-level outputs
├── terraform.tfvars.example   # Copy → terraform.tfvars to customize
├── .gitignore
│
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── s3/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🚀 Quick Start

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.3.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- An AWS account with permissions to create VPC, EC2, IAM, and S3 resources

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/terraform-aws-starter-kit.git
cd terraform-aws-starter-kit
```

### 2. Configure your variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Review the plan
```bash
terraform plan
```

### 5. Apply the infrastructure
```bash
terraform apply
```

### 6. Connect to your EC2 instance (via SSM — no SSH key required)
```bash
aws ssm start-session --target $(terraform output -raw ec2_instance_id)
```

---

## 🔧 Configuration

All variables have sensible defaults. The most common overrides:

| Variable | Description | Default |
|---|---|---|
| `aws_region` | AWS region | `us-east-1` |
| `project_name` | Resource name prefix | `my-project` |
| `environment` | dev / staging / prod | `dev` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `allowed_ssh_cidr` | IP range for SSH | `0.0.0.0/0` |
| `s3_versioning_enabled` | Enable S3 versioning | `true` |

> ⚠️ **Security**: Set `allowed_ssh_cidr` to your own IP (`YOUR_IP/32`) before deploying to production.

---

## 🧹 Destroy

To tear down all resources:
```bash
terraform destroy
```

> **Note**: If `s3_force_destroy = false` (default), the S3 bucket must be empty before destroy will succeed.

---

## 🔒 Security Considerations

- EC2 instance uses **IMDSv2** — protects against SSRF attacks
- S3 bucket enforces **HTTPS** — all HTTP requests are denied
- **No hardcoded credentials** — all access via IAM roles
- **`terraform.tfvars` is gitignored** — secrets stay local
- SSH is optional — **SSM Session Manager** provides credential-free shell access

---

## 📈 Extending This Kit

This starter kit is designed to be extended. Ideas:

- Add an **RDS module** (PostgreSQL/MySQL in private subnets)
- Add an **ALB module** (Application Load Balancer with SSL)
- Configure **remote state** with S3 + DynamoDB locking
- Add **CloudWatch alarms** for EC2 CPU/disk/memory
- Integrate with **GitHub Actions** for CI/CD (`.github/workflows/terraform.yml`)

---

## 📄 License

MIT © [Anas Tanveer](https://github.com/Anas Tanveer)
