# main.tf

module "vpc" {
  source     = "./modules/vpc"
  name       = "${var.project_name}-vpc"
  cidr_block = var.vpc_cidr_block
}

module "subnets" {
  source               = "./modules/subnet"
  project_name         = var.project_name
  region               = var.region
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "s3" {
  source        = "./modules/s3"
  project_name  = var.project_name
  bucket_suffix = var.s3_bucket_suffixes
}

module "rds" {
  source         = "./modules/rds"
  project_name   = var.project_name
  db_username    = var.db_username
  db_password    = var.db_password
  instance_class = var.db_instance
  engine         = var.db_engine
  engine_version = var.db_engine_version
  storage_type   = var.db_storage_type
  multi_az       = var.db_multi_az
  identifier     = "${var.project_name}-rds"
  subnet_ids = [
    module.subnets.private_subnet_ids["a-1"],
    module.subnets.private_subnet_ids["c-1"]
  ]
}

module "sqs" {
  source            = "./modules/sqs"
  project_name      = var.project_name
  queue_names       = var.sqs_fifo_queue_names
  dlq_queue_names   = var.sqs_fifo_dlq_queue_names
  max_receive_count = var.sqs_fifo_max_receive_count
}