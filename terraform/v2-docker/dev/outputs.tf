output "nextjs_external_ip" {
  description = "Next.js 인스턴스의 외부 IP 주소"
  value       = module.compute.nextjs_external_ip
}

output "nextjs_internal_ip" {
  description = "Next.js 인스턴스의 외부 IP 주소"
  value       = module.compute.nextjs_internal_ip
}

output "springboot_external_ip" {
  description = "Spring Boot 인스턴스의 내부 IP 주소"
  value       = module.compute.springboot_external_ip
}

output "springboot_internal_ip" {
  description = "Spring Boot 인스턴스의 내부 IP 주소"
  value       = module.compute.springboot_internal_ip
}

#output "db_external_ip" {
#  description = "Spring Boot 인스턴스의 내부 IP 주소"
#  value       = module.compute.db_external_ip
#}

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

#output "redis_host" {
#  description = "Memorystore Redis 호스트 주소"
#  value       = module.memorystore.host
#}
#
#output "redis_port" {
#  description = "Memorystore Redis 포트"
#  value       = module.memorystore.port
#}

