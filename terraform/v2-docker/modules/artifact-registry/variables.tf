# modules/artifact_registry/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "nextjs_repo_name" {
  description = "Next.js Docker 이미지를 저장할 Artifact Registry 저장소 이름"
  type        = string
}

variable "springboot_repo_name" {
  description = "Spring Boot Docker 이미지를 저장할 Artifact Registry 저장소 이름"
  type        = string
}

variable "db_repo_name" {
  description = "MySQL/Redis Docker 이미지를 저장할 Artifact Registry 저장소 이름"
  type        = string
}
