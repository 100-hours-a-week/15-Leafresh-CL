resource "kubernetes_stateful_set" "this" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels    = { app = var.name }
  }

  spec {
    service_name = var.service_name
    replicas     = var.replicas
    selector {
      match_labels = { app = var.name }
    }
    template {
      metadata {
        labels = { app = var.name }
      }
      spec {
        container {
          name  = var.name
          image = var.container_image
          port {
            container_port = var.container_port
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/config"
          }
        }
        volume {
          name = "config"
          config_map {
            name = var.config_map_name
          }
        }
      }
    }
  }
}