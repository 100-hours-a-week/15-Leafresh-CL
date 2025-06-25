# modules/s3/main.tf

locals {
  logs_bucket_name = "${var.project_name}-s3-logs"
  images_bucket_name = "${var.project_name}-s3-images"

  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
  }, var.additional_tags)
}

# 1. 로그 저장을 위한 S3 버킷 (No change)
resource "aws_s3_bucket" "logs_bucket" {
  bucket = local.logs_bucket_name
  tags = merge(local.common_tags, {
    Name = local.logs_bucket_name
    Purpose = "Access Logs"
  })
}

# Public Access Block for Logs Bucket (No change)
resource "aws_s3_bucket_public_access_block" "logs_bucket_public_access_block" {
  bucket = aws_s3_bucket.logs_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-Side Encryption Configuration for Logs Bucket (No change)
resource "aws_s3_bucket_server_side_encryption_configuration" "logs_bucket_sse" {
  bucket = aws_s3_bucket.logs_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACL for Logs Bucket (No change)
resource "aws_s3_bucket_acl" "logs_bucket_acl" {
  bucket = aws_s3_bucket.logs_bucket.id
  acl    = "log-delivery-write"
}


# 2. 이미지 저장을 위한 S3 버킷 (No change)
resource "aws_s3_bucket" "images_bucket" {
  bucket = local.images_bucket_name
  tags = merge(local.common_tags, {
    Name = local.images_bucket_name
    Purpose = "Application Images"
  })
}

# Public Access Block for Images Bucket (No change)
resource "aws_s3_bucket_public_access_block" "images_bucket_public_access_block" {
  bucket = aws_s3_bucket.images_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-Side Encryption Configuration for Images Bucket (No change)
resource "aws_s3_bucket_server_side_encryption_configuration" "images_bucket_sse" {
  bucket = aws_s3_bucket.images_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ACL for Images Bucket (No change)
resource "aws_s3_bucket_acl" "images_bucket_acl" {
  bucket = aws_s3_bucket.images_bucket.id
  acl    = "private"
}

# Versioning Configuration for Images Bucket (CORRECTED BLOCK NAME)
resource "aws_s3_bucket_versioning" "images_bucket_versioning" {
  bucket = aws_s3_bucket.images_bucket.id
  # CORRECTION: Changed 'configuration' to 'versioning_configuration'
  versioning_configuration {
    status = "Enabled" # Versioning을 활성화합니다.
  }
}
