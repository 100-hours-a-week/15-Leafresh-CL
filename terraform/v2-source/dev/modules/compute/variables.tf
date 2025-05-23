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

variable "mysql_root_password" {
  description = "MySQL root 비밀번호"
  type        = string
  sensitive   = true
}

variable "db_user" {
  description = "MySQL db 사용자 이름"
  type        = string
  sensitive   = true
}

variable "db_user_password" {
  description = "MySQL db 사용자 비밀번호"
  type        = string
  sensitive   = true
}

variable "mysql_database" {
  description = "MySQL 초기 DB 이름"
  default     = "leafresh"
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
