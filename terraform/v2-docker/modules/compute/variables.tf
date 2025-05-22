# modules/compute/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "zone" {
  description = "GCP 존"
  type        = string
}

variable "nextjs_subnet_self_link" {
  description = "Next.js Public Subnet의 Self Link"
  type        = string
}

variable "springboot_subnet_self_link" {
  description = "Spring Boot Private Subnet의 Self Link"
  type        = string
}

variable "db_subnet_self_link" {
  description = "MySQL 및 Redis Private Subnet의 Self Link"
  type        = string
}

variable "nextjs_tag" {
  description = "Next.js 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "springboot_tag" {
  description = "Spring Boot 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "db_tag" {
  description = "MySQL/Redis 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "nextjs_docker_image" {
  description = "Next.js Docker 이미지 경로"
  type        = string
}

variable "springboot_docker_image" {
  description = "Spring Boot Docker 이미지 경로"
  type        = string
}

variable "mysql_docker_image" {
  description = "MySQL Docker 이미지 경로"
  type        = string
}

variable "redis_docker_image" {
  description = "Redis Docker 이미지 경로"
  type        = string
}

variable "gcs_bucket_name" {
  description = "Spring Boot와 연결할 GCS 버킷명"
  type        = string
}

variable "cloud_dns_zone_name" {
  description = "기존 Cloud DNS Zone의 이름"
  type        = string
}

variable "cloud_dns_record_name" {
  description = "Cloud DNS에서 생성할 A 레코드의 이름"
  type        = string
}
