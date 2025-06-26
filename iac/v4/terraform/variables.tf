# variables.tf (Root Module)
variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "leafresh-vpc"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/18)."
  type        = string
  default     = "10.0.0.0/18"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster to tag subnets for."
  type        = string
  default     = "my-eks-cluster"
}

variable "availability_zones" {
  description = "List of availability zones to deploy resources into."
  type        = list(string)
  default = [
    "ap-northeast-2a",
    "ap-northeast-2b"
  ]
}

variable "subnet_configs" {
  description = "List of configurations for various subnet types."
  type = list(object({
    name_suffix             = string
    type                    = string # "public" or "private"
    cidr_offset             = number
    prefix_length           = number
    map_public_ip_on_launch = optional(bool, false)
  }))
  default = [
    # Public Web Tier Subnets (예: 웹 서버, 로드 밸런서)
    {
      name_suffix             = "lb"
      type                    = "public"
      cidr_offset             = 0  # 예: VPC CIDR에서 첫 번째 /20 블록 사용
      prefix_length           = 22 # /22 서브넷
      map_public_ip_on_launch = true
    },
    # Private Application Tier Subnets (예: 애플리케이션 서버, EC2 인스턴스)
    {
      name_suffix             = "ai"
      type                    = "private"
      cidr_offset             = 1  # 예: VPC CIDR에서 두 번째 /20 블록 사용
      prefix_length           = 22 # /22 서브넷
      map_public_ip_on_launch = false
    },
    # Private Data Tier Subnets (예: RDS, ElastiCache)
    {
      name_suffix             = "db"
      type                    = "private"
      cidr_offset             = 2  # 예: VPC CIDR에서 세 번째 /20 블록 사용
      prefix_length           = 22 # /22 서브넷
      map_public_ip_on_launch = false
    },
    # EKS Private Subnets (EKS 워커 노드용)
    {
      name_suffix             = "eks"
      type                    = "private"
      cidr_offset             = 3  # VPC CIDR에서 네 번째 /20 블록 사용
      prefix_length           = 21 # /22 서브넷
      map_public_ip_on_launch = false
    },
    # Monitoring Private Subnets (모니터링 서버용)
    {
      name_suffix             = "monitoring"
      type                    = "private"
      cidr_offset             = 4  # VPC CIDR에서 다섯 번째 /20 블록 사용
      prefix_length           = 22 # /22 서브넷
      map_public_ip_on_launch = false
    },
    # Monitoring Private Subnets (모니터링 서버용)
    {
      name_suffix             = "ops"
      type                    = "private"
      cidr_offset             = 5  # VPC CIDR에서 다섯 번째 /20 블록 사용
      prefix_length           = 22 # /22 서브넷
      map_public_ip_on_launch = false
    }
  ]
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks that are allowed to SSH into instances."
  type        = list(string)
  # !!! 중요: 실제 환경에서는 이곳을 외부에서 SSH 접속이 필요한 특정 IP 대역으로 제한해야 합니다.
  # 예: ["203.0.113.0/24"] 또는 여러분의 사무실/VPN IP
  default = ["0.0.0.0/0"] # 경고: 이 설정은 모든 IP에서 SSH를 허용하므로 프로덕션 환경에서는 절대 사용하지 마십시오.
}

variable "project_name" {
  description = "The overall project name for resource naming and tagging."
  type        = string
  default     = "leafresh"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

# SQS Queue Variables - Order Main Queue Defaults
variable "order_queue_delay_seconds" {
  description = "The length of time, in seconds, for which the delivery of all messages in the order queue is delayed."
  type        = number
  default     = 0
}

variable "order_queue_max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it for the order queue."
  type        = number
  default     = 262144 # 256 KB
}

variable "order_queue_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the order queue."
  type        = number
  default     = 345600 # 4 days
}

variable "order_queue_receive_wait_time_seconds" {
  description = "The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive in the order queue."
  type        = number
  default     = 0 # Short polling
}

variable "order_queue_visibility_timeout_seconds" {
  description = "The length of time, in seconds, that a message is hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request in the order queue."
  type        = number
  default     = 30
}

variable "order_queue_max_receive_count" {
  description = "The number of times a message is delivered to the source queue before being moved to the dead-letter queue."
  type        = number
  default     = 5 # 메시지가 DLQ로 가기 전 최대 5번 재시도
}

# SQS Queue Variables - Order DLQ Defaults
variable "order_dlq_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the order DLQ."
  type        = number
  default     = 1209600 # 14 days, DLQ는 일반적으로 더 긴 보존 기간
}

# SQS Queue Variables - Send to AI Queue Defaults
variable "send_to_ai_queue_delay_seconds" {
  description = "The length of time, in seconds, for which the delivery of all messages in the send-to-AI queue is delayed."
  type        = number
  default     = 0
}

variable "send_to_ai_queue_max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it for the send-to-AI queue."
  type        = number
  default     = 262144 # 256 KB
}

variable "send_to_ai_queue_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the send-to-AI queue."
  type        = number
  default     = 345600 # 4 days
}

variable "send_to_ai_queue_receive_wait_time_seconds" {
  description = "The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive in the send-to-AI queue."
  type        = number
  default     = 0
}

variable "send_to_ai_queue_visibility_timeout_seconds" {
  description = "The length of time, in seconds, that a message is hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request in the send-to-AI queue."
  type        = number
  default     = 30
}

# SQS Queue Variables - Send to Backend Queue Defaults
variable "send_to_be_queue_delay_seconds" {
  description = "The length of time, in seconds, for which the delivery of all messages in the send-to-BE queue is delayed."
  type        = number
  default     = 0
}

variable "send_to_be_queue_max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it for the send-to-BE queue."
  type        = number
  default     = 262144 # 256 KB
}

variable "send_to_be_queue_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the send-to-BE queue."
  type        = number
  default     = 345600 # 4 days
}

variable "send_to_be_queue_receive_wait_time_seconds" {
  description = "The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive in the send-to-BE queue."
  type        = number
  default     = 0
}

variable "send_to_be_queue_visibility_timeout_seconds" {
  description = "The length of time, in seconds, that a message is hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request in the send-to-BE queue."
  type        = number
  default     = 30
}

# RDS Instance Variables
variable "db_engine" {
  description = "The database engine to use (e.g., postgres, mysql)."
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "The database engine version."
  type        = string
  default     = "8.0" # PostgreSQL 14.7 (원하는 버전에 따라 변경)
}

variable "db_instance_class" {
  description = "The EC2 instance type for the RDS instance."
  type        = string
  default     = "db.t3.micro" # 개발/테스트용
  # default     = "db.r6g.large" # 프로덕션용 예시
}

variable "db_allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
  default     = 5 # 5GB
}

variable "db_storage_type" {
  description = "The storage type (e.g., gp2, gp3, io1)."
  type        = string
  default     = "gp3"
}

variable "db_storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "db_multi_az" {
  description = "Specifies if the DB instance is a Multi-AZ deployment."
  type        = bool
  default     = false # 개발/테스트용 (고가용성 비활성화)
  # default     = true # 프로덕션용 (고가용성 활성화)
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = "leafreshdb"
}

variable "db_username" {
  description = "Username for the master DB user."
  type        = string
  default     = "leafreshadmin"
}

variable "db_password" {
  description = "Password for the master DB user. Use a secure method to provide this (e.g., AWS Secrets Manager, Terraform Cloud variables)."
  type        = string
  # default     = "YourSecurePasswordHere" # !!! NEVER HARDCODE IN PRODUCTION !!!
  sensitive = true
}

variable "db_port" {
  description = "The port on which the DB accepts connections."
  type        = number
  default     = 5432 # PostgreSQL 기본 포트
}

variable "db_skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true # 개발/테스트용 (스냅샷 스킵)
  # default     = false # 프로덕션용 (스냅샷 생성)
}

variable "db_backup_retention_period" {
  description = "The number of days to retain backups."
  type        = number
  default     = 7
}
