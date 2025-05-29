# modules/network/variables.tf

variable "project_id_dev" {
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

variable "vpc_name_dev" {
  description = "GCP 프로젝트 이름"
  type        = string
}

variable "vpc_name_gpu1" {
  description = "GPU1 VPC 이름"
  type        = string
}

variable "vpc_name_gpu2" {
  description = "GPU2 VPC 이름"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "subnet_name_fe" {
  description = "FE 서브넷 이름"
  type        = string
}

variable "subnet_name_be" {
  description = "BE 서브넷 이름"
  type        = string
}

variable "subnet_name_db" {
  description = "DB 서브넷 이름"
  type        = string
}

variable "subnet_cidr_fe" {
  description = "Next.js Public Subnet의 CIDR 블록"
  type        = string
}

variable "subnet_cidr_be" {
  description = "Spring Boot Private Subnet의 CIDR 블록"
  type        = string
}

variable "subnet_cidr_db" {
  description = "MySQL 및 Redis Private Subnet의 CIDR 블록"
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC (from vpc module)"
  type        = string
}

variable "nat_ip" {
  description = "NAT IP 주소"
  type        = string
}

variable "nat_router" {
  description = "NAT 라우터 이름"
  type        = string
}

variable "nat_gateway" {
  description = "NAT 게이트웨이 이름"
  type        = string
}

variable "static_ip_name_fe" {
  description = "FE 외부 IP 이름"
  type        = string
}

variable "static_ip_name_be" {
  description = "BE 외부 IP 이름"
  type        = string
}