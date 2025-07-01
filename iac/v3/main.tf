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

module "sqs" {
  source            = "./modules/sqs"
  project_name      = var.project_name
  queue_names       = var.sqs_fifo_queue_names
  dlq_queue_names   = var.sqs_fifo_dlq_queue_names
  max_receive_count = var.sqs_fifo_max_receive_count
}

module "rds" {
  source         = "./modules/rds"
  project_name   = var.project_name
  instance_class = var.rds_instance_class
  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  multi_az       = var.rds_multi_az
  db_username    = var.rds_username
  db_password    = var.rds_password
  storage_type   = var.rds_storage_type
  subnet_ids = [
    module.subnets.private_subnet_ids_map["a-2"],
    module.subnets.private_subnet_ids_map["c-2"]
  ]
}

module "ec2" {
  source       = "./modules/ec2"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id # VPC 모듈 outputs 중 ID
  region       = var.region
  ec2_nodes    = local.ec2_nodes
}

module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  security_group_ids = [module.ec2.sg_k8s_id]
  instance_id_k8s_worker_fe = module.ec2.instance_ids[2]
  instance_id_monitoring = module.ec2.instance_ids[0]
  instance_id_argocd = module.ec2.instance_ids[5]
}

module "asg" {
  source             = "./modules/asg"
  project_name       = var.project_name
  launch_template_id = module.ec2.launch_templates["k8s-worker"]
  target_group_arn   = module.alb.target_group_arn_fe
  subnet_ids         = local.asg_k8s.subnet_ids
  min_size           = local.asg_k8s.min_size
  max_size           = local.asg_k8s.max_size
  desired_capacity   = local.asg_k8s.desired_capacity
}

module "ecr" {
  source           = "./modules/ecr"
  project_name     = var.project_name
  repository_names = var.ecr_repository_names
}
