resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"
  tags = {
    Name = "${var.project_name}-acm-${var.tag}"
  }
}

