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

variable "vpc_name_dev" {
  description = "GCP VPC 이름"
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

#variable "subnet_cidr_db" {
#  description = "MySQL 및 Redis Private Subnet의 CIDR 블록"
#  type        = string
#}

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

#variable "subnet_name_db" {
#  description = "DB 서브넷 이름"
#  type        = string
#}

# variable "nat_ip" {
#   description = "NAT IP 주소"
#   type        = string
# }

# variable "nat_router" {
#   description = "NAT 라우터 이름"
#   type        = string
# }

# variable "nat_gateway" {
#   description = "NAT 게이트웨이 이름"
#   type        = string
# }

variable "static_ip_name_fe" {
  description = "NAT IP 주소"
  type        = string
}

variable "static_ip_name_be" {
  description = "NAT IP 주소"
  type        = string
}

#variable "static_ip_name_db" {
#  description = "DB 외부 IP 이름"
#  type        = string
#}



# compute 변수
variable "static_internal_ip_fe" {
  description = "Next.js 인스턴스의 내부 IP"
  type        = string
}

variable "static_internal_ip_be" {
  description = "Spring Boot 인스턴스의 내부 IP"
  type        = string
}

#variable "static_internal_ip_db" {
#  description = "DB 인스턴스의 내부 IP"
#  type        = string
#}

variable "tag_fe" {
  description = "Next.js 인스턴스에 적용할 네트워크 태그"
  type        = string
}

variable "tag_be" {
  description = "Spring Boot 인스턴스에 적용할 네트워크 태그"
  type        = string
}

#variable "tag_db" {
#  description = "MySQL/Redis 인스턴스에 적용할 네트워크 태그"
#  type        = string
#}

variable "gce_name_fe" {
  description = "fe 인스턴스 이름"
  type        = string
}

variable "gce_name_be" {
  description = "be 인스턴스 이름"
  type        = string
}

#variable "gce_name_db" {
#  description = "db 인스턴스 이름"
#  type        = string
#}

variable "gce_machine_type_fe" {
  description = "GCE FE용 VM 타입"
  type        = string
}

variable "gce_machine_type_be" {
  description = "GCE BE용 VM 타입"
  type        = string
}

#variable "gce_machine_type_db" {
#  description = "GCE BE용 VM 타입"
#  type        = string
#}

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

#variable "startup_db_mysql_root_password" {
#  description = "DB 인스턴스 루트 계정 비밀번호"
#  type        = string
#}
#
#variable "startup_db_mysql_database_name" {
#  description = "DB 인스턴스 데이터베이스 이름"
#  type        = string
#}
#
#variable "startup_db_redis_port" {
#  description = "DB 인스턴스 redis 포트 번호"
#  type        = string
#}
#
#variable "startup_db_redis_host" {
#  description = "DB 인스턴스 redis 호스트 이름"
#  type        = string
#}



# Cloud SQL 변수
variable "sql_instance_name" {
  description = "Cloud SQL 인스턴스 이름"
  type        = string
}

variable "sql_database_name" {
  description = "Cloud SQL에 생성할 데이터베이스 이름"
  type        = string
}

variable "sql_root_password" {
  description = "Cloud SQL 루트 비밀번호"
  type        = string
  sensitive   = true
}

variable "sql_tier" {
  description = "Cloud SQL Tier"
  type        = string
  default     = "db-f1-micro"
}

variable "sql_database_version" {
  description = "Cloud SQL 데이터베이스 버전"
  type        = string
  default     = "MYSQL_8_0"
}

variable "sql_allocated_storage" {
  description = "Cloud SQL 저장공간 크기(GB)"
  type        = number
  default     = 10
}

variable "authorized_networks" {
  description = "Cloud SQL Public IP에 접근을 허용할 CIDR 목록"
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}


# Memorystore Redis 변수
#variable "redis_instance_name" {
#  description = "Memorystore Redis 인스턴스 이름"
#  type        = string
#}
#
#variable "redis_tier" {
#  description = "Memorystore Tier"
#  type        = string
#  default     = "BASIC"
#}
#
#variable "redis_memory_size_gb" {
#  description = "Redis 메모리 크기(GB)"
#  type        = number
#  default     = 2
#}



# Pub/Sub 변수
variable "pubsub_topic_names" {
  type = map(object({
    subscription_name = string
  }))
  description = "pub/sub topics and subscriptions"
}




# storage 변수
variable "storage_buckets_config" {
  description = "A map of configurations for multiple GCS buckets."
  type = map(object({
    name              = string
    storage_class     = string
    force_destroy     = bool
    environment_label = string
    purpose_label     = string
    cors_config = object({
      origin          = list(string)
      method          = list(string)
      response_header = list(string)
      max_age_seconds = number
    })
  }))
}




# iam 변수
variable "iam_project_bindings" {
  description = "프로젝트 권한과 멤버 바인딩"
  type = list(object({
    role    = string
    members = list(string)
  }))
}

variable "iam_storage_bindings_per_bucket" {
  description = "A map where keys are GCS bucket config keys and values are lists of IAM bindings for that bucket."
  type = map(list(object({
    role    = string
    members = list(string)
  })))
  default = {}
}

