variable "project_id" {
  type = string
  description = "GCP Project ID"
}

variable "zone" {
  type = string
  description = "GCP Zone"
}

variable "public_subnet_id" {
  type = string
  description = "Public Subnet ID"
}

variable "private_app_subnet_id" {
  type = string
  description = "Private Subnet (App) ID"
}

variable "private_db_subnet_id" {
  type = string
  description = "Private Subnet (DB) ID"
}

variable "nextjs_instance_name" {
  type = string
  description = "Next.js 인스턴스 이름"
}

variable "springboot_instance_name" {
  type = string
  description = "SpringBoot 인스턴스 이름"
}

variable "tags" {
  type = map(string)
  description = "리소스 태그"
}
