# 방화벽 모듈 호출
module "firewall" {
  source                        = "./modules/firewall"
  project_id                    = var.project_id
  network_name                  = module.network.vpc_name
  nextjs_tag                    = var.nextjs_tag
  springboot_tag                = var.springboot_tag
  db_tag                        = var.db_tag
  gpu1_instance_vpc_name        = var.gpu_instance_vpc_name
  gpu1_instance_vpc_cidr_blocks = var.gpu_instance_vpc_cidr_blocks
  gpu2_instance_vpc_name        = var.gpu_instance_vpc_name
  gpu2_instance_vpc_cidr_blocks = var.gpu_instance_vpc_cidr_blocks
}
# 네트워크 모듈 호출
module "network" {
  source                 = "./modules/network"
  project_id             = var.project_id
  region                 = var.region
  vpc_cidr_block         = var.vpc_cidr_block
  nextjs_subnet_cidr     = var.nextjs_subnet_cidr
  springboot_subnet_cidr = var.springboot_subnet_cidr
  db_subnet_cidr         = var.db_subnet_cidr
}

# Compute 모듈 호출
module "compute" {
  source                      = "./modules/compute"
  project_id                  = var.project_id
  region                      = var.region
  zone                        = var.zone
  nextjs_subnet_self_link     = module.network.nextjs_subnet_self_link
  springboot_subnet_self_link = module.network.springboot_subnet_self_link
  db_subnet_self_link         = module.network.db_subnet_self_link
  nextjs_tag                  = var.nextjs_tag
  springboot_tag              = var.springboot_tag
  db_tag                      = var.db_tag
  gcs_bucket_name             = var.gcs_bucket_name
  cloud_dns_zone_name         = var.cloud_dns_zone_name
  cloud_dns_record_name       = var.cloud_dns_record_name
  mysql_root_password         = var.mysql_root_password
  db_user                     = var.db_user
  db_user_password            = var.db_user_password
}

# Pub/Sub 모듈 호출
module "pubsub" {
  source     = "./modules/pubsub"
  project_id = var.project_id
  project_number = var.project_number
}
