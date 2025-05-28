# modules/network/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "project_id_gpu1" {
  description = "GCP GPU1 프로젝트 ID"
  type        = string
}

variable "project_id_gpu2" {
  description = "GCP GPU2 프로젝트 ID"
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

variable "dev_cidr_block" {
  description = "VPC의 CIDR 블록"
  type        = string
  default     = "10.0.1.0/22"
}

variable "gpu1_cidr_block" {
  description = "VPC의 CIDR 블록"
  type        = string
  default     = "10.0.3.0/24"
}

variable "gpu2_cidr_block" {
  description = "VPC의 CIDR 블록"
  type        = string
  default     = "10.0.4.0/24"
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
