# Changelog

All notable changes are listed here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org).

## [1.0.0] - 2026-10-13

### Added

- Modules: `vpc`, `alb`, `waf`, `ec2`, `s3`, `kms` and `monitoring`.
- `dev`, `staging` and `prod` environments, each with its own variables file and backend file.
- `bootstrap/` stack: KMS-encrypted state bucket with S3 native locking, GitHub OIDC provider, a read-only plan role and an opt-in apply role.
- AWS WAF with managed rule groups, a per-IP rate limit and redacted logs (`enable_waf`).
- ALB access logs in a dedicated bucket (`enable_alb_access_logs`).
- A p95 latency alarm and a CloudWatch dashboard (`dashboard_url` output).
- `ami_id`, to pin the instance AMI instead of tracking the latest Amazon Linux 2023.
- A `prod_https` check that warns when prod has no certificate.
- CI workflows:
  - `terraform.yml`: fmt, validate, test, tflint, trivy and a terraform-docs check; plans on pull requests, applies on `main`.
  - `apply.yml`: applies one environment, gated by its GitHub environment.
  - `drift.yml`: scheduled drift detection.
- Dependabot for GitHub Actions and Terraform providers.
- 20 `terraform test` cases run against a mocked AWS provider.

### Security

- The CI plan role is read-only (CI plans with `-lock=false`) and is trusted only for pull requests and `main`.
- The flow-log role trust policy is scoped with `aws:SourceAccount` and `aws:SourceArn`.
- IAM policy ARNs are partition-aware.

### Fixed

- Pull request runs no longer cancel in-progress runs on `main`, which could have interrupted an apply.
- The target group uses `name_prefix` with `create_before_destroy`, so replacing it no longer fails with `ResourceInUse`.

[1.0.0]: https://github.com/anastanveer653/terraform-aws-starter-kit/releases/tag/v1.0.0
