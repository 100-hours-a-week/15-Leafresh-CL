# variables.tf (Root Module)
variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "MyArchitectureVPC"
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

# Define the base /19 CIDR block for each AZ, derived from the /18 VPC.
# This assumes the VPC is always /18 and AZs split it into /19s.
variable "az_base_cidrs" {
  description = "Map of AZ to its base /19 CIDR block within the VPC."
  type        = map(string)
  default = {
    "ap-northeast-2a" = "10.0.0.0/19"
    "ap-northeast-2b" = "10.0.32.0/19"
  }
  # You could also calculate this dynamically if your VPC CIDR might change:
  # value = {
  #   "ap-northeast-2a" = cidrsubnet(var.vpc_cidr_block, 19, 0)
  #   "ap-northeast-2b" = cidrsubnet(var.vpc_cidr_block, 19, 1)
  # }
}


# These are the offsets *within* each AZ's /19 block.
# We need to ensure these offsets are valid given the `prefix_length` (e.g., newbits).
# Calculate the number of smaller blocks a /19 can be split into:
# For /22: 2^(22-19) = 2^3 = 8 subnets (offsets 0-7)
# For /20: 2^(20-19) = 2^1 = 2 subnets (offsets 0-1)
# For /23: 2^(23-19) = 2^4 = 16 subnets (offsets 0-15)
# For /24: 2^(24-19) = 2^5 = 32 subnets (offsets 0-31)

variable "subnet_offsets" {
  description = "Map of subnet type to its offset within the AZ's base /19 CIDR block. These are sequential indexes."
  type        = map(number)
  default = {
    # Public subnet: /22. `newbits` = 22-19 = 3. Max offset = 2^3 - 1 = 7.
    # Start at 0: 10.0.0.0/22 (from 10.0.0.0/19)
    public       = 0

    # EKS subnet: /20. `newbits` = 20-19 = 1. Max offset = 2^1 - 1 = 1.
    # To place it after public (which uses 10.0.0.0/22, 10.0.4.0/22, 10.0.8.0/22, 10.0.12.0/22)
    # The smallest /20 block starts at offset 0 (10.0.0.0/20) or offset 1 (10.0.16.0/20).
    # Since public is 10.0.0.0/22, which is part of 10.0.0.0/20, EKS must start after that.
    # Let's allocate 10.0.16.0/20 for EKS. This means offset 1 for /20.
    eks          = 1

    # Data subnet: /23. `newbits` = 23-19 = 4. Max offset = 2^4 - 1 = 15.
    # Public (10.0.0.0/22) consumes 10.0.0.0-10.0.3.255.
    # EKS (10.0.16.0/20) consumes 10.0.16.0-10.0.31.255.
    # Remaining from 10.0.0.0/19 (10.0.0.0-10.0.31.255): 10.0.4.0-10.0.15.255
    # Let's use `10.0.4.0/23`. This corresponds to offset 2 for /23 subnets.
    # (10.0.0.0/23 is offset 0, 10.0.2.0/23 is offset 1, 10.0.4.0/23 is offset 2)
    data         = 2

    # App subnet: /23. Next available after data.
    # 10.0.6.0/23 corresponds to offset 3.
    app          = 3

    # Ops subnet: /24. `newbits` = 24-19 = 5. Max offset = 2^5 - 1 = 31.
    # 10.0.8.0/24 corresponds to offset 4.
    ops          = 4

    # Monitoring subnet: /24. Next available after ops.
    # 10.0.9.0/24 corresponds to offset 5.
    monitoring   = 5

    # Reserved subnet: /22. `newbits` = 22-19 = 3. Max offset = 2^3 - 1 = 7.
    # 10.0.12.0/22 corresponds to offset 3.
    # This might overlap with previous if offsets are small for large blocks.
    # Let's ensure these offsets are genuinely sequential and non-overlapping based on the *actual CIDRs*.
    # A more robust way is to use `cidrsubnets` or `for` loops to assign:

    # Let's calculate the `offset` for `cidrsubnet(10.0.0.0/19, new_prefix, offset)`:
    # Public (/22): 10.0.0.0/22. Offset: 0. (uses /22)
    # EKS (/20): 10.0.16.0/20. Offset: 1. (uses /20)
    # Data (/23): 10.0.4.0/23. Offset: 2. (uses /23)
    # App (/23): 10.0.6.0/23. Offset: 3. (uses /23)
    # Ops (/24): 10.0.8.0/24. Offset: 4. (uses /24)
    # Monitoring (/24): 10.0.9.0/24. Offset: 5. (uses /24)
    # Reserved (/22): 10.0.12.0/22. Offset: 3. (uses /22)

    # Let's re-align the `subnet_offsets` values to be correct relative to the /19 base.
    # We need to manually calculate the appropriate `netnum` for each.
    # For AZ 'a' (base 10.0.0.0/19):
    # Public (/22): `cidrsubnet("10.0.0.0/19", 22, 0)` -> 10.0.0.0/22
    # EKS (/20): `cidrsubnet("10.0.0.0/19", 20, 1)` -> 10.0.16.0/20
    # Data (/23): `cidrsubnet("10.0.0.0/19", 23, 2)` -> 10.0.4.0/23
    # App (/23): `cidrsubnet("10.0.0.0/19", 23, 3)` -> 10.0.6.0/23
    # Ops (/24): `cidrsubnet("10.0.0.0/19", 24, 8)` -> 10.0.8.0/24 (Offset 8 for /24)
    # Monitoring (/24): `cidrsubnet("10.0.0.0/19", 24, 9)` -> 10.0.9.0/24 (Offset 9 for /24)
    # Reserved (/22): `cidrsubnet("10.0.0.0/19", 22, 3)` -> 10.0.12.0/22

    public       = 0  # 10.0.0.0/22 (from 10.0.0.0/19)
    eks          = 1  # 10.0.16.0/20 (from 10.0.0.0/19)
    data         = 2  # 10.0.4.0/23 (from 10.0.0.0/19)
    app          = 3  # 10.0.6.0/23 (from 10.0.0.0/19)
    ops          = 4  # 10.0.8.0/24 (from 10.0.0.0/19)
    monitoring   = 5  # 10.0.9.0/24 (from 10.0.0.0/19)
    reserved     = 3  # 10.0.12.0/22 (from 10.0.0.0/19)
  }
}

variable "subnet_prefixes" {
  description = "Map of subnet type to its CIDR prefix length."
  type        = map(number)
  default = {
    public       = 22
    eks          = 20
    data         = 23
    app          = 23
    ops          = 24
    monitoring   = 24
    reserved     = 22
  }
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks that are allowed to SSH into instances."
  type        = list(string)
  # !!! 중요: 실제 환경에서는 이곳을 외부에서 SSH 접속이 필요한 특정 IP 대역으로 제한해야 합니다.
  # 예: ["203.0.113.0/24"] 또는 여러분의 사무실/VPN IP
  default     = ["0.0.0.0/0"] # 경고: 이 설정은 모든 IP에서 SSH를 허용하므로 프로덕션 환경에서는 절대 사용하지 마십시오.
}

variable "project_name" {
  description = "The overall project name for resource naming and tagging."
  type        = string
  default     = "leafresh" # 여기서 기본값 설정
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev" # 여기서 기본값 설정
}

variable "common_tags" {
  description = "A map of common tags to apply to all resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
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
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The database engine version."
  type        = string
  default     = "14.7" # PostgreSQL 14.7 (원하는 버전에 따라 변경)
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
  default     = 20 # 20GB
}

variable "db_storage_type" {
  description = "The storage type (e.g., gp2, gp3, io1)."
  type        = string
  default     = "gp2"
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
  # For local testing, you might use a tfvars file or env var.
  # If you do not provide a default here, Terraform will prompt you.
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
  default     = 7 # 7일
}
