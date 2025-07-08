# modules/lb_controller/ingress_https.tf
resource "kubernetes_ingress" "fe_https" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "alb"

      # HTTP(80) + HTTPS(443) 리스너 둘 다 생성
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([
        { HTTP = 80 },
        { HTTPS = 443 },
      ])
      "alb.ingress.kubernetes.io/certificate-arn"  = var.alb_certificate_arn
      "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  spec {
    rule {
      host = var.domain_name

      http {
        path {
          path = "/" # 원하는 path

          backend {
            service_name = var.service_name
            service_port = var.service_port
          }
        }
      }
    }
  }
}