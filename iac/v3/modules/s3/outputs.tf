# modules/s3/outputs.tf
output "bucket_ids" {
  value = { for s, b in aws_s3_bucket.this : s => b.id }
}