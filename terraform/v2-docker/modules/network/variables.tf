# modules/network/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
  type        = string
}

variable "nextjs_subnet_cidr" {
  description = "Next.js Public Subnet의 CIDR 블록"
  type        = string
}

variable "springboot_subnet_cidr" {
  description = "Spring Boot Private Subnet의 CIDR 블록"
  type        = string
}

variable "db_subnet_cidr" {
  description = "MySQL 및 Redis Private Subnet의 CIDR 블록"
  type        = string
}
