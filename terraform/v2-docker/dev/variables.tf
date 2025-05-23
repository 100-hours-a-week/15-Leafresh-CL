variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "project_number" {
  description = "GCP 프로젝트 번호"
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
  default     = "10.0.1.0/22"
}

variable "nextjs_subnet_cidr" {
  description = "Next.js Public Subnet의 CIDR 블록"
  type        = string
  default     = "10.0.1.0/26"
}

variable "springboot_subnet_cidr" {
  description = "Spring Boot Private Subnet의 CIDR 블록"
  type        = string
  default     = "10.0.1.64/26"
}

variable "db_subnet_cidr" {
  description = "MySQL 및 Redis Private Subnet의 CIDR 블록"
  type        = string
  default     = "10.0.1.128/26"
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

variable "mysql_root_password" {
  description = "MySQL root 비밀번호"
  type        = string
  sensitive   = true
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
  default     = "leafresh-images"
}

variable "cloud_dns_zone_name" {
  description = "기존 Cloud DNS Zone의 이름"
  type        = string
  default     = "dev-leafresh-app"
}

variable "cloud_dns_record_name" {
  description = "Cloud DNS에서 생성할 A 레코드의 이름"
  type        = string
  default     = "dev-leafresh.app"
}

variable "iap_user_email" {
  description = "IAP 터널링 권한을 부여할 GCP 사용자 이메일 주소"
  type        = string
}
