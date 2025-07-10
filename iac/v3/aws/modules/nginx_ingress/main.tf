resource "helm_release" "this" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  namespace        = var.namespace
  create_namespace = var.create_namespace

  set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
      value = "${var.project_name}-${var.name}"
    },
    {
      name  = "controller.service.type"
      value = var.service_type
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = var.load_balancer_type
    },
    {
      name  = "controller.publishService.enabled"
      value = tostring(var.publish_service_enabled)
    }
  ]
}
