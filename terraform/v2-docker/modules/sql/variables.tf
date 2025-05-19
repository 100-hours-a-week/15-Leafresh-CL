variable "project_id" {
  type = string
  description = "GCP Project ID"
}

variable "region" {
  type = string
  description = "GCP Region"
}

variable "private_db_subnet_id" {
  type = string
  description = "Private Subnet (DB) ID"
}

variable "mysql_instance_name" {
  type = string
  description = "MySQL 인스턴스 이름"
}

variable "tags" {
  type = map(string)
  description = "리소스 태그"
}
