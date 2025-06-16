# modules/sql/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "Cloud SQL 리전"
  type        = string
}

variable "network" {
  description = "VPC 네트워크 self_link"
  type        = string
}

variable "db_instance_name" {
  description = "Cloud SQL 인스턴스 이름"
  type        = string
}

variable "db_tier" {
  description = "Cloud SQL Tier"
  type        = string
}

variable "database_version" {
  description = "Cloud SQL 데이터베이스 버전"
  type        = string
}

variable "allocated_storage" {
  description = "저장공간 크기(GB)"
  type        = number
}

variable "database_name" {
  description = "최초 생성할 데이터베이스 이름"
  type        = string
}

variable "root_password" {
  description = "루트 사용자 비밀번호"
  type        = string
  sensitive   = true
}

