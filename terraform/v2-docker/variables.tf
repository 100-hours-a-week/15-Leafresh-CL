variable "project_id" {
  type = string
  description = "GCP Project ID"
  # default = "leafresh" # 실제 GCP 프로젝트 ID로 변경
}

variable "region" {
  type = string
  description = "GCP Region"
  # default = "asia-northeast3" # 필요에 따라 리전 변경
}

variable "zone" {
  type = string
  description = "GCP Zone"
  # default = "asia-northeast3-a" # 필요에 따라 가용성 영역 변경
}

variable "vpc_name" {
  type = string
  description = "VPC 네트워크 이름"
  # default = "three-tier-vpc"
}

variable "vpc_cidr" {
  type = string
  description = "VPC CIDR 블록"
  # default = "10.0.0.0/16"
}

variable "public_subnet_name" {
  type = string
  description = "Public Subnet 이름"
  # default = "public-subnet"
}

variable "public_subnet_cidr" {
  type = string
  description = "Public Subnet CIDR 블록"
  # default = "10.0.1.0/24"
}

variable "private_app_subnet_name" {
  type = string
  description = "Private Subnet (App) 이름"
  # default = "private-app-subnet"
}

variable "private_app_subnet_cidr" {
  type = string
  description = "Private Subnet (App) CIDR 블록"
  # default = "10.0.2.0/24"
}

variable "private_db_subnet_name" {
  type = string
  description = "Private Subnet (DB) 이름"
  # default = "private-db-subnet"
}

variable "private_db_subnet_cidr" {
  type = string
  description = "Private Subnet (DB) CIDR 블록"
  # default = "10.0.3.0/24"
}

variable "nextjs_instance_name" {
  type = string
  description = "Next.js 인스턴스 이름"
  # default = "nextjs-instance"
}

variable "springboot_instance_name" {
  type = string
  description = "SpringBoot 인스턴스 이름"
  # default = "springboot-instance"
}

variable "mysql_instance_name" {
  type = string
  description = "MySQL 인스턴스 이름"
  # default = "mysql-instance"
}

variable "redis_instance_name" {
  type = string
  description = "Redis 인스턴스 이름"
  # default = "redis-instance"
}

variable "existing_gpu_vpc_network" {
  type = string
  description = "기존 GPU 인스턴스 VPC 네트워크 이름"
  # default = "existing-gpu-vpc" # 실제 GPU 인스턴스 VPC 이름으로 변경
}

variable "existing_gpu_vpc_cidrs" {
  type = list(string)
  description = "기존 GPU 인스턴스 VPC CIDR 블록 목록"
  default = ["10.0.3.0/24", "10.0.4.0/24"] # 실제 GPU 인스턴스 VPC CIDR 목록으로 변경
}

variable "gcs_bucket_name" {
  type = string
  description = "GCS 버킷 이름"
  default = "leafresh-images"
}

variable "cloud_dns_zone_name" {
  type = string
  description = "Cloud DNS 영역 이름"
  # default = "leafresh-app"
}
