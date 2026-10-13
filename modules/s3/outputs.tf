output "bucket_name" {
  description = "Name of the bucket."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the bucket."
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the bucket."
  value       = aws_s3_bucket.this.id
}

output "public_access_fully_blocked" {
  description = "True when all four public access block settings are on."
  value = alltrue([
    aws_s3_bucket_public_access_block.this.block_public_acls,
    aws_s3_bucket_public_access_block.this.block_public_policy,
    aws_s3_bucket_public_access_block.this.ignore_public_acls,
    aws_s3_bucket_public_access_block.this.restrict_public_buckets,
  ])
}
