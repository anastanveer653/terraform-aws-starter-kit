output "state_bucket_name" {
  description = "Put this in environments/*.s3.tfbackend and in the TF_STATE_BUCKET repository variable."
  value       = aws_s3_bucket.state.bucket
}

output "state_kms_key_arn" {
  description = "KMS key that encrypts the state. Put it in environments/*.s3.tfbackend as kms_key_id."
  value       = aws_kms_key.state.arn
}

output "github_plan_role_arn" {
  description = "Put this in the AWS_PLAN_ROLE_ARN repository variable to enable plans in CI."
  value       = aws_iam_role.github_plan.arn
}

output "github_apply_role_arn" {
  description = "Put this in the AWS_APPLY_ROLE_ARN repository variable to apply on merge to main. Null unless create_github_apply_role is true."
  value       = try(aws_iam_role.github_apply[0].arn, null)
}
