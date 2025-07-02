// 1. ACM 인증서 요청 (DNS 검증)
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

// 2. GCP DNS 검증 레코드 생성
locals {
  dvo_list = tolist(aws_acm_certificate.cert.domain_validation_options)
}

resource "google_dns_record_set" "cert_validation" {
  name         = local.dvo_list[0].resource_record_name
  type         = local.dvo_list[0].resource_record_type
  ttl          = var.ttl
  managed_zone = var.gcp_managed_zone
  rrdatas      = [ local.dvo_list[0].resource_record_value ]
}

// 3. ACM 검증 완료
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [google_dns_record_set.cert_validation.name]
}

// 4. ALB HTTPS 리스너 생성
resource "aws_lb_listener" "https" {
  load_balancer_arn = var.alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.default_target_group_arn
  }
}

// 5. GCP DNS에 ALB 엔드포인트용 CNAME 레코드
resource "google_dns_record_set" "alb_alias" {
  name         = "${var.domain_name}."
  type         = "CNAME"
  ttl          = 300
  managed_zone = var.gcp_managed_zone
  rrdatas      = [var.alb_dns_name]
}
