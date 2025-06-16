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
#
#output "db_internal_ip" {
#  description = "MySQL/Redis 인스턴스의 내부 IP 주소"
#  value       = module.compute.db_internal_ip
#}

output "pubsub_topic_names" {
  description = "생성된 모든 Pub/Sub Topic 이름들"
  value       = module.pubsub.pubsub_topic_names
}

