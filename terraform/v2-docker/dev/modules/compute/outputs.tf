# modules/compute/outputs.tf

output "nextjs_external_ip" {
  description = "Next.js 인스턴스의 외부 IP 주소"
  value       = google_compute_instance.fe.network_interface[0].access_config[0].nat_ip
}

output "springboot_external_ip" {
  description = "Spring Boot 인스턴스의 외부 IP 주소"
  value       = google_compute_instance.be.network_interface[0].access_config[0].nat_ip
}

#output "db_external_ip" {
#  description = "Mysql/Redis 인스턴스의 외부 IP 주소"
#  value       = google_compute_instance.db.network_interface[0].access_config[0].nat_ip
#}

output "nextjs_internal_ip" {
  description = "Nextjs 인스턴스의 내부 IP 주소"
  value       = google_compute_instance.fe.network_interface[0].network_ip
}

output "springboot_internal_ip" {
  description = "Spring Boot 인스턴스의 내부 IP 주소"
  value       = google_compute_instance.be.network_interface[0].network_ip
}

#output "db_internal_ip" {
#  description = "MySQL/Redis 인스턴스의 내부 IP 주소"
#  value       = google_compute_instance.db.network_interface[0].network_ip
#}
