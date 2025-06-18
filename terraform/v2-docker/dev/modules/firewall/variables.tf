# modules/firewall/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "vpc_name" {
  description = "대상 VPC의 이름"
  type        = string
}

variable "tag_fe" {
  description = "Next.js 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_be" {
  description = "Spring Boot 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_vault" {
  description = "Vault 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_db" {
  description = "Redis 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "vpc_cidr_block_gpu1" {
  description = "GPU1 VPC의 CIDR"
  type        = string
}

variable "vpc_cidr_block_gpu2" {
  description = "GPU2 VPC의 CIDR"
  type        = string
}
