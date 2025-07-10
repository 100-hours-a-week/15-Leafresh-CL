resource "kubernetes_service" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal" = "true"
    }
  }
  spec {
    selector = { app = var.name }
    port {
      port        = var.port
      target_port = var.target_port
    }
    type = var.type
  }
}