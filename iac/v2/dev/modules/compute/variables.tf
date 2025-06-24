# modules/compute/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "GCP 리전"
  type        = string
}

variable "zone" {
  description = "GCP 존"
  type        = string
}

variable "static_ip_fe" {
  description = "FE 외부 IP 이름"
  type        = string
}

variable "static_ip_be" {
  description = "BE 외부 IP 이름"
  type        = string
}

variable "static_ip_vault" {
  description = "Vault 외부 IP 이름"
  type        = string
}

variable "static_internal_ip_fe" {
  description = "Next.js 인스턴스의 내부 IP"
  type        = string
}

variable "static_internal_ip_be" {
  description = "Spring Boot 인스턴스의 내부 IP"
  type        = string
}

variable "static_internal_ip_db" {
  description = "DB 인스턴스의 내부 IP"
  type        = string
}

variable "subnet_fe_self_link" {
  description = "Next.js Public Subnet의 Self Link"
  type        = string
}

variable "subnet_be_self_link" {
  description = "Spring Boot Private Subnet의 Self Link"
  type        = string
}

variable "subnet_db_self_link" {
  description = "MySQL 및 Redis Private Subnet의 Self Link"
  type        = string
}

variable "subnet_vault_self_link" {
  description = "Vault Public Subnet의 Self Link"
  type        = string
}

variable "tag_fe" {
  description = "Next.js 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_be" {
  description = "SpringBoot 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_db" {
  description = "Redis 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_vault" {
  description = "vault 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "name_fe" {
  description = "fe 인스턴스 이름"
  type        = string
}

variable "name_be" {
  description = "be 인스턴스 이름"
  type        = string
}

variable "name_db" {
  description = "db 인스턴스 이름"
  type        = string
}

variable "name_vault" {
  description = "vault 인스턴스 이름"
  type        = string
}

variable "dns_zone_name" {
  description = "기존 Cloud DNS Zone의 이름"
  type        = string
}

variable "dns_record_name" {
  description = "Cloud DNS에서 생성할 A 레코드의 이름"
  type        = string
}

variable "machine_type_fe" {
  description = "GCE FE용 VM 타입"
  type        = string
}

variable "machine_type_be" {
  description = "GCE BE용 VM 타입"
  type        = string
}

variable "machine_type_db" {
  description = "GCE BE용 VM 타입"
  type        = string
}

variable "machine_type_vault" {
  description = "GCE vault용 VM 타입"
  type        = string
}

variable "image" {
  description = "GCE VM 이미지"
  type        = string
}

variable "disk_size" {
  description = "GCE VM 디스크 크기"
  type        = string
}

variable "startup_fe_port" {
  description = "FE 인스턴스 포트 번호"
  type        = string
}

variable "startup_fe_container_name" {
  description = "FE 인스턴스 도커 컨테이너 이름 설정"
  type        = string
}

variable "startup_fe_image" {
  description = "FE 인스턴스 도커 사용 이미지 이름"
  type        = string
}

variable "startup_be_port" {
  description = "BE 인스턴스 포트 번호"
  type        = string
}

variable "startup_be_secret_name" {
  description = "BE 인스턴스 env 이름"
  type        = string
  sensitive   = true
}

variable "startup_be_secret_name_json" {
  description = "BE 인스턴스 json 이름"
  type        = string
  sensitive   = true
}

variable "startup_be_container_name" {
  description = "BE 인스턴스 도커 컨테이너 이름 설정"
  type        = string
}

variable "startup_be_image" {
  description = "BE 인스턴스 도커 사용 이미지 이름"
  type        = string
}

variable "startup_vault_port" {
  description = "BE 인스턴스 포트 번호"
  type        = string
}

variable "startup_vault_container_name" {
  description = "BE 인스턴스 도커 컨테이너 이름 설정"
  type        = string
}

variable "startup_vault_image" {
  description = "BE 인스턴스 도커 사용 이미지 이름"
  type        = string
}

#variable "startup_db_mysql_root_password" {
#  description = "DB 인스턴스 루트 계정 비밀번호"
#  type        = string
#}
#
#variable "startup_db_mysql_database_name" {
#  description = "DB 인스턴스 데이터베이스 이름"
#  type        = string
#}

variable "startup_db_redis_port" {
  description = "DB 인스턴스 redis 포트 번호"
  type        = string
}

variable "startup_db_redis_host" {
  description = "DB 인스턴스 redis 호스트 이름"
  type        = string
}
