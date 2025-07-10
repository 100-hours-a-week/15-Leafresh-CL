output "validation_complete" {
  description = "Dummy output to force dependency on ACM certificate validation"
  value       = aws_acm_certificate_validation.this.id
}
