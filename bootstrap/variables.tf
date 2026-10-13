variable "aws_region" {
  description = "Region for the state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for the state bucket and CI role."
  type        = string
  default     = "starter-kit"
}

variable "github_repository" {
  description = "GitHub repository (owner/name) allowed to assume the CI plan role."
  type        = string
  default     = "anastanveer653/terraform-aws-starter-kit"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$", var.github_repository))
    error_message = "github_repository must look like owner/name."
  }
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider. Set false if the account already has one."
  type        = bool
  default     = true
}

variable "create_github_apply_role" {
  description = "Create the CI apply role. Add required reviewers to the GitHub environments it trusts before enabling."
  type        = bool
  default     = false
}

variable "github_apply_environments" {
  description = "GitHub environments whose jobs may assume the apply role."
  type        = list(string)
  default     = ["dev", "prod"]
}
