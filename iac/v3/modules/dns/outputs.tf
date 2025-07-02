output "certificate_arn" {
  description = "발급된 ACM 인증서 ARN"
  value       = aws_acm_certificate.cert.arn
}

output "listener_arn" {
  description = "생성된 HTTPS 리스너 ARN"
  value       = aws_lb_listener.https.arn
}
