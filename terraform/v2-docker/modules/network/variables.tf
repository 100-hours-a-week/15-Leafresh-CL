variable "project_id" {
  type = string
  description = "GCP Project ID"
}

variable "region" {
  type = string
  description = "GCP Region"
}

variable "vpc_name" {
  type = string
  description = "VPC 네트워크 이름"
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR 블록"
}

variable "public_subnet_name" {
  type = string
  description = "Public Subnet 이름"
}

variable "public_subnet_cidr" {
  type = string
  description = "Public Subnet CIDR 블록"
}

variable "private_app_subnet_name" {
  type = string
  description = "Private Subnet (App) 이름"
}

variable "private_app_subnet_cidr" {
  type = string
  description = "Private Subnet (App) CIDR 블록"
}

variable "private_db_subnet_name" {
  type = string
  description = "Private Subnet (DB) 이름"
}

variable "private_db_subnet_cidr" {
  type = string
  description = "Private Subnet (DB) CIDR 블록"
}

variable "existing_gpu_vpc_network" {
  type = string
  description = "기존 GPU 인스턴스 VPC 네트워크 이름"
}

variable "existing_gpu_vpc_cidrs" {
  type = list(string)
  description = "기존 GPU 인스턴스 VPC CIDR 블록 목록"
}

variable "tags" {
  type = map(string)
  description = "리소스 태그"
}
