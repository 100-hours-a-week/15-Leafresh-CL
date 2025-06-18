output "fe_external_ip" {
  description = "Next.js 인스턴스의 외부 IP 주소"
  value       = module.compute.fe_external_ip
}

output "fe_internal_ip" {
  description = "Next.js 인스턴스의 외부 IP 주소"
  value       = module.compute.fe_internal_ip
}

output "be_external_ip" {
  description = "Spring Boot 인스턴스의 내부 IP 주소"
  value       = module.compute.be_external_ip
}

output "vault_external_ip" {
  description = "Vault 인스턴스의 내부 IP 주소"
  value       = module.compute.vault_external_ip
}

output "springboot_internal_ip" {
  description = "Spring Boot 인스턴스의 내부 IP 주소"
  value       = module.compute.springboot_internal_ip
}

output "db_internal_ip" {
  description = "MySQL/Redis 인스턴스의 내부 IP 주소"
  value       = module.compute.db_internal_ip
}

output "pubsub_topic_names" {
  description = "생성된 모든 Pub/Sub Topic 이름들"
  value       = module.pubsub.pubsub_topic_names
}

output "sql_private_ip" {
  description = "Cloud SQL Private IP 주소"
  value       = module.sql.private_ip_address
}
