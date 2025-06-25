# modules/s3/outputs.tf

output "logs_bucket_name" {
  description = "The name of the S3 bucket for logs."
  value       = aws_s3_bucket.logs_bucket.bucket
}

output "logs_bucket_id" {
  description = "The ID of the S3 bucket for logs."
  value       = aws_s3_bucket.logs_bucket.id
}

output "images_bucket_name" {
  description = "The name of the S3 bucket for images."
  value       = aws_s3_bucket.images_bucket.bucket
}

output "images_bucket_id" {
  description = "The ID of the S3 bucket for images."
  value       = aws_s3_bucket.images_bucket.id
}
