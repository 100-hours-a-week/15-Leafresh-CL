# VPC 모듈
module "vpc" {
  source       = "./modules/vpc"
  project_id   = var.project_id_dev
  project_name = var.project_name_dev
}

# 방화벽 모듈
module "firewall" {
  source         = "./modules/firewall"
  project_id_dev = var.project_id_dev
  vpc_name       = module.vpc.vpc_name

  tag_fe = var.tag_fe
  tag_be = var.tag_be
  tag_db = var.tag_db

  # vpc_name_gpu1        = var.vpc_name_gpu1
  vpc_cidr_block_gpu1 = var.vpc_cidr_block_gpu1
  # vpc_name_gpu2        = var.vpc_name_gpu2
  vpc_cidr_block_gpu2 = var.vpc_cidr_block_gpu2
}

# 네트워크 모듈
module "network" {
  source          = "./modules/network"
  region          = var.region
  project_id_dev  = var.project_id_dev
  project_id_gpu1 = var.project_id_gpu1
  project_id_gpu2 = var.project_id_gpu2
  vpc_name_dev    = module.vpc.vpc_name
  vpc_name_gpu1   = var.vpc_name_gpu1
  vpc_name_gpu2   = var.vpc_name_gpu2

  nat_ip      = var.nat_ip
  nat_router  = var.nat_router
  nat_gateway = var.nat_gateway

  static_ip_name_fe = var.static_ip_name_fe
  static_ip_name_be = var.static_ip_name_be

  subnet_name_fe = var.subnet_name_fe
  subnet_name_be = var.subnet_name_be
  subnet_name_db = var.subnet_name_db

  # vpc_cidr_block         = var.vpc_cidr_block

  subnet_cidr_fe = var.subnet_cidr_fe
  subnet_cidr_be = var.subnet_cidr_be
  subnet_cidr_db = var.subnet_cidr_db

  vpc_self_link = module.vpc.vpc_self_link
}

# VM 모듈
module "compute" {
  zone           = var.zone
  source         = "./modules/compute"
  region         = var.region
  project_id_dev = var.project_id_dev

  static_ip_fe = module.network.static_ip_fe
  static_ip_be = module.network.static_ip_be


  static_internal_ip_fe = var.static_internal_ip_fe
  static_internal_ip_be = var.static_internal_ip_be
  static_internal_ip_db = var.static_internal_ip_db

  subnet_fe_self_link = module.network.subnet_fe_self_link
  subnet_be_self_link = module.network.subnet_be_self_link
  subnet_db_self_link = module.network.subnet_db_self_link

  tag_fe = var.tag_fe
  tag_be = var.tag_be
  tag_db = var.tag_db

  gce_name_fe = var.gce_name_fe
  gce_name_be = var.gce_name_be
  gce_name_db = var.gce_name_db

  gce_machine_type_fe = var.gce_machine_type_fe
  gce_machine_type_be = var.gce_machine_type_be
  gce_machine_type_db = var.gce_machine_type_db

  gce_image = var.gce_image

  gce_disk_size = var.gce_disk_size

  dns_zone_name   = var.dns_zone_name
  dns_record_name = var.dns_record_name

  startup_fe_image               = var.startup_fe_image
  startup_fe_container_name      = var.startup_fe_container_name
  startup_fe_nextjs_port         = var.startup_fe_nextjs_port
  startup_be_image               = var.startup_be_image
  startup_be_container_name      = var.startup_be_container_name
  startup_be_secret_name         = var.startup_be_secret_name
  startup_be_springboot_port     = var.startup_be_springboot_port
  startup_db_mysql_database_name = var.startup_db_mysql_database_name
  startup_db_mysql_root_password = var.startup_db_mysql_root_password
  startup_db_redis_host          = var.startup_db_redis_host
  startup_db_redis_port          = var.startup_db_redis_port
}

# Pub/Sub 모듈
module "pubsub" {
  source         = "./modules/pubsub"
  project_id_dev = var.project_id_dev
  project_number = var.project_number

  pubsub_topic_name        = var.pubsub_topic_name
  pubsub_subscription_name = var.pubsub_subscription_name
}


# Storage 모듈
module "storage" {
  source                = "./modules/storage"
  storage_name          = var.storage_name
  project_id_dev        = var.project_id_dev
  region                = var.region
  storage_class         = var.storage_class
  storage_force_destroy = true

  storage_cors_origin          = var.storage_cors_origin
  storage_cors_method          = var.storage_cors_method
  storage_cors_response_header = var.storage_cors_response_header
  storage_cors_max_age_seconds = var.storage_cors_max_age_seconds
}



# IAM 모듈
module "iam" {
  source         = "./modules/iam"
  project_id_dev = var.project_id_dev
  storage_name   = module.storage.storage_name
  iam_bindings   = var.iam_bindings
}

