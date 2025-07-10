# modules/s3/main.tf
resource "aws_s3_bucket" "this" {
  for_each = toset(var.bucket_suffix)
  bucket   = "${var.project_name}-${each.value}"
  tags = {
    Name = "${var.project_name}-${each.value}"
  }
}

