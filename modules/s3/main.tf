locals {
  bucket_name = var.bucket_name != "" ? var.bucket_name : "${var.project_name}-${var.environment}-${var.account_id}"
}

# ─────────────────────────────────────────────
# S3 Bucket
# ─────────────────────────────────────────────
resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy

  tags = {
    Name = local.bucket_name
  }
}

# ─────────────────────────────────────────────
# Block all public access (security best practice)
# ─────────────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─────────────────────────────────────────────
# Versioning
# ─────────────────────────────────────────────
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = var.versioning_enabled ? "Enabled" : "Suspended"
  }
}

# ─────────────────────────────────────────────
# Server-Side Encryption (AES-256)
# ─────────────────────────────────────────────
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# ─────────────────────────────────────────────
# Lifecycle Rules — auto-archive old versions
# ─────────────────────────────────────────────
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 90
      storage_class   = "GLACIER"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }

  rule {
    id     = "expire-incomplete-multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

# ─────────────────────────────────────────────
# Bucket Policy — enforce HTTPS only
# ─────────────────────────────────────────────
resource "aws_s3_bucket_policy" "https_only" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyHTTP"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.main]
}
