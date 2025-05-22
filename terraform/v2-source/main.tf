# 방화벽 모듈 호출
module "firewall" {
  source                       = "./modules/firewall"
  project_id                   = var.project_id
  network_name                 = module.network.vpc_name
  nextjs_tag                   = var.nextjs_tag
  springboot_tag               = var.springboot_tag
  db_tag                       = var.db_tag
  gpu_instance_vpc_name        = var.gpu_instance_vpc_name
  gpu_instance_vpc_cidr_blocks = var.gpu_instance_vpc_cidr_blocks
}

# Compute 모듈 호출
module "compute" {
  source                  = "./modules/compute"
  project_id              = var.project_id
  region                  = var.region
  zone                    = var.zone
  nextjs_subnet_self_link = module.network.nextjs_subnet_self_link
  springboot_subnet_self_link = module.network.springboot_subnet_self_link
  db_subnet_self_link     = module.network.db_subnet_self_link
  nextjs_tag              = var.nextjs_tag
  springboot_tag          = var.springboot_tag
  db_tag                  = var.db_tag
  gcs_bucket_name         = var.gcs_bucket_name
  cloud_dns_zone_name     = var.cloud_dns_zone_name
  cloud_dns_record_name   = var.cloud_dns_record_name
}

# Pub/Sub 모듈 호출
module "pubsub" {
  source     = "./modules/pubsub"
  project_id = var.project_id
}
