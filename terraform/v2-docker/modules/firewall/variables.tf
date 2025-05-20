# modules/firewall/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "network_name" {
  description = "대상 VPC의 이름"
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

variable "gpu1_instance_vpc_name" {
  description = "기존 GPU instance VPC의 이름"
  type        = string
}

variable "gpu1_instance_vpc_cidr_blocks" {
  description = "기존 GPU instance VPC의 CIDR 블록 리스트"
  type        = list(string)
}

variable "gpu2_instance_vpc_name" {
  description = "기존 GPU instance VPC의 이름"
  type        = string
}

variable "gpu2_instance_vpc_cidr_blocks" {
  description = "기존 GPU instance VPC의 CIDR 블록 리스트"
  type        = list(string)
}
