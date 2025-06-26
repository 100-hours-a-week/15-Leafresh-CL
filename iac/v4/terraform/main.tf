# main.tf (Root Module)
locals {
  nat_gateway_ids_map = {
    for az in var.availability_zones : az => module.gateways.natgw_ids[az]
  }
}

module "vpc" {
  source     = "./modules/vpc"
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
}

module "subnets" {
  source             = "./modules/subnets"
  vpc_id             = module.vpc.vpc_id
  vpc_name           = var.vpc_name
  environment        = var.environment
  vpc_cidr_block     = var.vpc_cidr_block
  availability_zones = var.availability_zones
  subnet_configs     = var.subnet_configs
}

module "gateways" {
  source             = "./modules/gateway"
  vpc_id             = module.vpc.vpc_id
  vpc_name           = var.vpc_name
  public_subnet_ids  = module.subnets.public_subnets_map
  private_subnet_ids = module.subnets.private_subnets_map
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = var.vpc_cidr_block
  vpc_name          = var.vpc_name
  allowed_ssh_cidrs = var.allowed_ssh_cidrs # SSH 허용 CIDR
}

# S3 Buckets
module "s3_buckets" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# SQS
module "sqs_queues" {
  source = "./modules/sqs"

  project_name = var.project_name
  environment  = var.environment

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

  database_subnet_ids        = module.subnets.subnet_ids_by_suffix["db"]
  database_security_group_id = module.security_groups.db_sg_id

  engine                  = var.db_engine
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_type            = var.db_storage_type
  storage_encrypted       = var.db_storage_encrypted
  multi_az                = var.db_multi_az
  name                    = var.db_name
  username                = var.db_username
  password                = var.db_password
  port                    = var.db_port
  skip_final_snapshot     = var.db_skip_final_snapshot
  backup_retention_period = var.db_backup_retention_period
}
