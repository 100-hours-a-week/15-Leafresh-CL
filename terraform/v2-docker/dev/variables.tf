# project 공통 변수
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

variable "project_name_dev" {
  description = "GCP 프로젝트 이름"
  type        = string
}

variable "project_number" {
  description = "GCP 프로젝트 번호"
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




# firewall 변수
variable "vpc_cidr_block" {
  description = "VPC의 CIDR 블록"
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

variable "vpc_name_gpu1" {
  description = "기존 GPU1 instance VPC의 이름"
  type        = string
}

variable "vpc_name_gpu2" {
  description = "기존 GPU2 instance VPC의 이름"
  type        = string
}

variable "vpc_cidr_block_gpu1" {
  description = "기존 GPU instance VPC의 CIDR 블록 리스트"
  type        = string
}

variable "vpc_cidr_block_gpu2" {
  description = "기존 GPU instance VPC의 CIDR 블록 리스트"
  type        = string
}




# network 변수
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
  description = "NAT IP 주소"
  type        = string
}

variable "static_ip_name_be" {
  description = "NAT IP 주소"
  type        = string
}


# compute 변수
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

variable "tag_fe" {
  description = "Next.js 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_be" {
  description = "Spring Boot 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_db" {
  description = "MySQL/Redis 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "gce_name_fe" {
  description = "fe 인스턴스 이름"
  type        = string
}

variable "gce_name_be" {
  description = "be 인스턴스 이름"
  type        = string
}

variable "gce_name_db" {
  description = "db 인스턴스 이름"
  type        = string
}

variable "gce_machine_type_fe" {
  description = "GCE FE용 VM 타입"
  type        = string
}

variable "gce_machine_type_be" {
  description = "GCE BE용 VM 타입"
  type        = string
}

variable "gce_machine_type_db" {
  description = "GCE BE용 VM 타입"
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

variable "gce_image" {
  description = "GCE VM 이미지"
  type        = string
}

variable "gce_disk_size" {
  description = "GCE VM 디스크 크기"
  type        = string
}

variable "startup_fe_nextjs_port" {
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

variable "startup_be_springboot_port" {
  description = "BE 인스턴스 env 이름"
  type        = string
}

variable "startup_be_secret_name" {
  description = "BE 인스턴스 env 이름"
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

variable "startup_db_mysql_root_password" {
  description = "DB 인스턴스 루트 계정 비밀번호"
  type        = string
}

variable "startup_db_mysql_database_name" {
  description = "DB 인스턴스 데이터베이스 이름"
  type        = string
}

variable "startup_db_redis_port" {
  description = "DB 인스턴스 redis 포트 번호"
  type        = string
}

variable "startup_db_redis_host" {
  description = "DB 인스턴스 redis 호스트 이름"
  type        = string
}



# Pub/Sub 변수
variable "pubsub_topic_name" {
  description = "GCP 토픽 이름"
  type        = string
}

variable "pubsub_subscription_name" {
  description = "GCP 구독 이름"
  type        = string
}



# Storage 변수
variable "storage_name" {
  description = "GCS 버킷 이름"
  type        = string
}

variable "storage_class" {
  description = "버킷 클래스"
  type        = string
  default     = "STANDARD"
}

variable "storage_force_destroy" {
  description = "버킷 내 객체와 버킷 자체 강제 삭제"
  type        = bool
  default     = false
}

variable "storage_cors_origin" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "storage_cors_method" {
  description = "Allowed CORS HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD", "PUT", "POST", "DELETE"]
}

variable "storage_cors_response_header" {
  description = "Allowed response headers"
  type        = list(string)
  default     = ["*"]
}

variable "storage_cors_max_age_seconds" {
  description = "Max age for CORS options"
  type        = number
  default     = 3600
}




# iam 변수
variable "iam_bindings" {
  description = "IAM bindings to be applied"
  type = list(object({
    role   = string
    member = string
  }))
}

