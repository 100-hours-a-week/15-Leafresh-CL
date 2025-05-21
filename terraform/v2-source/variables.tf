variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
  default     = "asia-northeast3" # 서울 리전
}

variable "zone" {
  description = "GCP 존"
  type        = string
  default     = "asia-northeast3-a"
}

variable "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "nextjs_subnet_cidr" {
  description = "Next.js Public Subnet의 CIDR 블록"
  type        = string
  default     = "10.0.1.0/24"
}

variable "springboot_subnet_cidr" {
  description = "Spring Boot Private Subnet의 CIDR 블록"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_cidr" {
  description = "MySQL 및 Redis Private Subnet의 CIDR 블록"
  type        = string
  default     = "10.0.3.0/24"
}

variable "nextjs_tag" {
  description = "Next.js 인스턴스에 적용할 네트워크 태그"
  type        = string
  default     = "nextjs-instance"
}

variable "springboot_tag" {
  description = "Spring Boot 인스턴스에 적용할 네트워크 태그"
  type        = string
  default     = "springboot-instance"
}

variable "db_tag" {
  description = "MySQL/Redis 인스턴스에 적용할 네트워크 태그"
  type        = string
  default     = "db-instance"
}

variable "gpu_instance_vpc_name" {
  description = "기존 GPU instance VPC의 이름"
  type        = string
  default     = "existing-gpu-vpc" # 실제 GPU VPC 이름으로 변경 필요
}

variable "gpu_instance_vpc_cidr_blocks" {
  description = "기존 GPU instance VPC의 CIDR 블록 리스트"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"] # 실제 GPU VPC CIDR로 변경 필요
}

variable "gcs_bucket_name" {
  description = "Spring Boot와 연결할 GCS 버킷명"
  type        = string
  default     = "leafresh-images" # 실제 GCS 버킷명으로 변경 필요
}

variable "cloud_dns_zone_name" {
  description = "기존 Cloud DNS Zone의 이름"
  type        = string
  default     = "leafresh-app" # 실제 Cloud DNS Zone 이름으로 변경 필요
}

variable "cloud_dns_record_name" {
  description = "Cloud DNS에서 생성할 A 레코드의 이름"
  type        = string
  default     = "leafresh.app."
}
