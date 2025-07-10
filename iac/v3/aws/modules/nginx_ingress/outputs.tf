output "release_name" {
  description = "Helm release name"
  value       = helm_release.this.name
}

output "namespace" {
  description = "Namespace where ingress is installed"
  value       = var.namespace
}
