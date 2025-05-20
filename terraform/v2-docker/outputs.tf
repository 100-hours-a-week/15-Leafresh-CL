output "nextjs_external_ip" {
  description = "Next.js 인스턴스의 외부 IP 주소"
  value       = module.compute.nextjs_external_ip
}

output "springboot_internal_ip" {
  description = "Spring Boot 인스턴스의 내부 IP 주소"
  value       = module.compute.springboot_internal_ip
}

output "db_internal_ip" {
  description = "MySQL/Redis 인스턴스의 내부 IP 주소"
  value       = module.compute.db_internal_ip
}

output "artifact_registry_nextjs_repo_url" {
  description = "Next.js Artifact Registry 저장소 URL"
  value       = module.artifact_registry.nextjs_repo_url
}

output "artifact_registry_springboot_repo_url" {
  description = "Spring Boot Artifact Registry 저장소 URL"
  value       = module.artifact_registry.springboot_repo_url
}

output "artifact_registry_db_repo_url" {
  description = "DB Artifact Registry 저장소 URL"
  value       = module.artifact_registry.db_repo_url
}

output "pubsub_topic_name" {
  description = "Pub/Sub Topic 이름"
  value       = module.pubsub.pubsub_topic_name
}
