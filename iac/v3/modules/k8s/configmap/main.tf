resource "kubernetes_config_map" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }
  data = var.data
}