# modules/artifact_registry/main.tf

resource "google_artifact_registry_repository" "nextjs_repo" {
  project      = var.project_id
  location     = var.region
  repository_id = var.nextjs_repo_name
  format       = "DOCKER"
  description  = "Docker repository for Next.js images"
}

resource "google_artifact_registry_repository" "springboot_repo" {
  project      = var.project_id
  location     = var.region
  repository_id = var.springboot_repo_name
  format       = "DOCKER"
  description  = "Docker repository for Spring Boot images"
}

resource "google_artifact_registry_repository" "db_repo" {
  project      = var.project_id
  location     = var.region
  repository_id = var.db_repo_name
  format       = "DOCKER"
  description  = "Docker repository for MySQL/Redis images"
}

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
