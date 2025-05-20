terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 네트워크 모듈 호출
module "network" {
  source                = "./modules/network"
  project_id            = var.project_id
  vpc_cidr_block        = var.vpc_cidr_block
  nextjs_subnet_cidr    = var.nextjs_subnet_cidr
  springboot_subnet_cidr = var.springboot_subnet_cidr
  db_subnet_cidr        = var.db_subnet_cidr
}

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

# Artifact Registry 모듈 호출
module "artifact_registry" {
  source     = "./modules/artifact_registry"
  project_id = var.project_id
  region     = var.region
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
  nextjs_docker_image     = "${module.artifact_registry.nextjs_repo_host}/${var.project_id}/${var.nextjs_repo_name}:${var.nextjs_docker_image_tag}"
  springboot_docker_image = "${module.artifact_registry.springboot_repo_host}/${var.project_id}/${var.springboot_repo_name}:${var.springboot_docker_image_tag}"
  mysql_docker_image      = "${module.artifact_registry.db_repo_host}/${var.project_id}/${var.db_repo_name}:${var.mysql_docker_image_tag}"
  redis_docker_image      = "${module.artifact_registry.db_repo_host}/${var.project_id}/${var.db_repo_name}:${var.redis_docker_image_tag}"
  gcs_bucket_name         = var.gcs_bucket_name
  cloud_dns_zone_name     = var.cloud_dns_zone_name
  cloud_dns_record_name   = var.cloud_dns_record_name
}

# Pub/Sub 모듈 호출
module "pubsub" {
  source     = "./modules/pubsub"
  project_id = var.project_id
}
