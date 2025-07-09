output "name" {
  value = kubernetes_service.this.metadata[0].name
}
output "port" {
  value = kubernetes_service.this.spec[0].port[0].port
}