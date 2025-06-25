# main.tf (Root Module)
locals {
  nat_gateway_ids_map = {
    for az in var.availability_zones : az => module.network_gateways.natgw_ids[az]
  }
}

module "vpc" {
  source     = "./modules/vpc"
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
}

module "network_gateways" {
  source            = "./modules/gateway"
  vpc_id            = module.vpc.vpc_id
  vpc_name          = var.vpc_name
  public_subnet_ids = module.public_subnets.subnet_ids
}

# Public Subnets
module "public_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs         # Pass the /19 base for each AZ
  offset                  = var.subnet_offsets.public # Pass the offset within the /19
  prefix_length           = var.subnet_prefixes.public
  name_prefix             = "Public"
  map_public_ip_on_launch = true
  is_public               = true
  internet_gateway_id     = module.network_gateways.igw_id
  needs_route_table       = true
}

# Private EKS Subnets
module "private_eks_subnets" {
  source = "./modules/subnets"

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  base_az_cidr_block = var.az_base_cidrs
  offset             = var.subnet_offsets.eks
  prefix_length      = var.subnet_prefixes.eks
  name_prefix        = "Private-EKS"
  nat_gateway_ids    = local.nat_gateway_ids_map
  additional_tags = {
    "kubernetes.io/role/internal-elb"               = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Private Data Subnets
module "private_data_subnets" {
  source = "./modules/subnets"

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  base_az_cidr_block = var.az_base_cidrs
  offset             = var.subnet_offsets.data
  prefix_length      = var.subnet_prefixes.data
  name_prefix        = "Private-DataTier"
  nat_gateway_ids    = local.nat_gateway_ids_map
}

# Private App Workload Subnets
module "private_app_workload_subnets" {
  source = "./modules/subnets"

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  base_az_cidr_block = var.az_base_cidrs
  offset             = var.subnet_offsets.app
  prefix_length      = var.subnet_prefixes.app
  name_prefix        = "Private-AppWorkload"
  nat_gateway_ids    = local.nat_gateway_ids_map
}

# Private Ops Tools Subnets
module "private_ops_tools_subnets" {
  source = "./modules/subnets"

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  base_az_cidr_block = var.az_base_cidrs
  offset             = var.subnet_offsets.ops
  prefix_length      = var.subnet_prefixes.ops
  name_prefix        = "Private-OpsTools"
  nat_gateway_ids    = local.nat_gateway_ids_map
}

# Private Monitoring Subnets
module "private_monitoring_subnets" {
  source = "./modules/subnets"

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  base_az_cidr_block = var.az_base_cidrs
  offset             = var.subnet_offsets.monitoring
  prefix_length      = var.subnet_prefixes.monitoring
  name_prefix        = "Private-Monitoring"
  nat_gateway_ids    = local.nat_gateway_ids_map
}

# Private Reserved Subnets
module "private_reserved_subnets" {
  source = "./modules/subnets"

  vpc_id             = module.vpc.vpc_id
  availability_zones = var.availability_zones
  base_az_cidr_block = var.az_base_cidrs
  offset             = var.subnet_offsets.reserved
  prefix_length      = var.subnet_prefixes.reserved
  name_prefix        = "Private-Reserved"
  nat_gateway_ids    = local.nat_gateway_ids_map
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = var.vpc_cidr_block    # VPC CIDR 블록 전달
  name_prefix       = var.vpc_name          # 보안 그룹 이름에 VPC 이름을 접두사로 사용
  allowed_ssh_cidrs = var.allowed_ssh_cidrs # SSH 허용 CIDR 전달
}

# S3 Buckets
module "s3_buckets" {
  source = "./modules/s3"

  # variables.tf에서 정의된 루트 변수들을 S3 모듈로 전달
  project_name    = var.project_name
  environment     = var.environment
  additional_tags = var.common_tags # 모든 리소스에 적용될 공통 태그
}

# SQS
module "sqs_queues" {
  source = "./modules/sqs"

  project_name    = var.project_name
  environment     = var.environment
  additional_tags = var.common_tags

  # Order Queue Variables (Main Queue)
  order_queue_delay_seconds              = var.order_queue_delay_seconds
  order_queue_max_message_size           = var.order_queue_max_message_size
  order_queue_message_retention_seconds  = var.order_queue_message_retention_seconds
  order_queue_receive_wait_time_seconds  = var.order_queue_receive_wait_time_seconds
  order_queue_visibility_timeout_seconds = var.order_queue_visibility_timeout_seconds
  order_queue_max_receive_count          = var.order_queue_max_receive_count # DLQ 연결 위한 변수

  # Order DLQ Variables
  order_dlq_message_retention_seconds = var.order_dlq_message_retention_seconds

  # Send to AI Queue Variables
  send_to_ai_queue_delay_seconds              = var.send_to_ai_queue_delay_seconds
  send_to_ai_queue_max_message_size           = var.send_to_ai_queue_max_message_size
  send_to_ai_queue_message_retention_seconds  = var.send_to_ai_queue_message_retention_seconds
  send_to_ai_queue_receive_wait_time_seconds  = var.send_to_ai_queue_receive_wait_time_seconds
  send_to_ai_queue_visibility_timeout_seconds = var.send_to_ai_queue_visibility_timeout_seconds

  # Send to Backend Queue Variables
  send_to_be_queue_delay_seconds              = var.send_to_be_queue_delay_seconds
  send_to_be_queue_max_message_size           = var.send_to_be_queue_max_message_size
  send_to_be_queue_message_retention_seconds  = var.send_to_be_queue_message_retention_seconds
  send_to_be_queue_receive_wait_time_seconds  = var.send_to_be_queue_receive_wait_time_seconds
  send_to_be_queue_visibility_timeout_seconds = var.send_to_be_queue_visibility_timeout_seconds
}

# RDS
module "rds_instance" {
  source = "./modules/rds"

  project_name = var.project_name
  environment  = var.environment
  additional_tags = var.common_tags
  
  database_subnet_ids      = values(module.private_data_subnets.subnet_ids)
  database_security_group_id = module.security_groups.database_access_sg_id

  db_engine                  = var.db_engine
  db_engine_version          = var.db_engine_version
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  db_storage_type            = var.db_storage_type
  db_storage_encrypted       = var.db_storage_encrypted
  db_multi_az                = var.db_multi_az
  db_name                    = var.db_name
  db_username                = var.db_username
  db_password                = var.db_password
  db_port                    = var.db_port
  db_skip_final_snapshot     = var.db_skip_final_snapshot
  db_backup_retention_period = var.db_backup_retention_period
}
