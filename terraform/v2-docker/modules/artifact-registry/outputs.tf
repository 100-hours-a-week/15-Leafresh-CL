# modules/artifact_registry/outputs.tf

output "nextjs_repo_url" {
  description = "Next.js Artifact Registry 저장소 URL"
  value       = google_artifact_registry_repository.nextjs_repo.name
}

output "nextjs_repo_host" {
  description = "Next.js Artifact Registry 저장소 호스트"
  value       = "${var.region}-docker.pkg.dev"
}

output "springboot_repo_url" {
  description = "Spring Boot Artifact Registry 저장소 URL"
  value       = google_artifact_registry_repository.springboot_repo.name
}

output "springboot_repo_host" {
  description = "Spring Boot Artifact Registry 저장소 호스트"
  value       = "${var.region}-docker.pkg.dev"
}

output "db_repo_url" {
  description = "DB Artifact Registry 저장소 URL"
  value       = google_artifact_registry_repository.db_repo.name
}

output "db_repo_host" {
  description = "DB Artifact Registry 저장소 호스트"
  value       = "${var.region}-docker.pkg.dev"
}
