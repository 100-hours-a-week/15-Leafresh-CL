variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  default     = "asia-northeast3"
}

variable "zone" {
  description = "GCP 존"
  default     = "asia-northeast3-a"
}

variable "instance_name" {
  description = "인스턴스 이름"
  default     = "leafresh-gce-db"
}

variable "machine_type" {
  description = "커스텀 머신 타입 (e2-custom-1-3072: 1vCPU, 3GB RAM)"
  default     = "e2-custom-1-3072"
}

variable "network" {
  description = "VPC 네트워크 이름"
  type        = string
}

variable "subnetwork" {
  description = "DB 서브넷 이름"
  type        = string
}

variable "service_account_email" {
  description = "서비스 계정 이메일"
  type        = string
}

variable "mysql_root_password" {
  description = "MySQL root 비밀번호"
  type        = string
  sensitive   = true
}

variable "mysql_database" {
  description = "MySQL 초기 DB 이름"
  default     = "leafresh"
}