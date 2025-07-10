output "name" {
  description = "The name of the config map"
  value       = kubernetes_config_map.this.metadata[0].name
}
