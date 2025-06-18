# modules/compute/outputs.tf

output "fe_external_ip" {
  description = "Next.js 인스턴스의 외부 IP 주소"
  value       = google_compute_instance.fe.network_interface[0].access_config[0].nat_ip
}

output "be_external_ip" {
  description = "Spring Boot 인스턴스의 외부 IP 주소"
  value       = google_compute_instance.be.network_interface[0].access_config[0].nat_ip
}

output "vault_external_ip" {
  description = "Vault 인스턴스의 외부 IP 주소"
  value       = google_compute_instance.vault.network_interface[0].access_config[0].nat_ip
}

output "fe_internal_ip" {
  description = "Nextjs 인스턴스의 내부 IP 주소"
  value       = google_compute_instance.fe.network_interface[0].network_ip
}

output "be_internal_ip" {
  description = "Spring Boot 인스턴스의 내부 IP 주소"
  value       = google_compute_instance.be.network_interface[0].network_ip
}

output "db_internal_ip" {
  description = "MySQL/Redis 인스턴스의 내부 IP 주소"
  value       = google_compute_instance.db.network_interface[0].network_ip
}
