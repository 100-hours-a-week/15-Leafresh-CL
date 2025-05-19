module "network" {
  source = "./modules/network"

  project_id                = var.project_id
  region                    = var.region
  vpc_name                  = var.vpc_name
  vpc_cidr                  = var.vpc_cidr
  public_subnet_name        = var.public_subnet_name
  public_subnet_cidr        = var.public_subnet_cidr
  private_app_subnet_name   = var.private_app_subnet_name
  private_app_subnet_cidr   = var.private_app_subnet_cidr
  private_db_subnet_name    = var.private_db_subnet_name
  private_db_subnet_cidr    = var.private_db_subnet_cidr
  existing_gpu_vpc_network  = var.existing_gpu_vpc_network
  existing_gpu_vpc_cidrs    = var.existing_gpu_vpc_cidrs
  tags                      = {
    "environment" = "dev"
    "team"        = "leafresh"
  }
}

module "compute" {
  source = "./modules/compute"

  project_id            = var.project_id
  zone                = var.zone
  public_subnet_id    = module.network.public_subnet_id
  private_app_subnet_id = module.network.private_app_subnet_id
  private_db_subnet_id  = module.network.private_db_subnet_id
  nextjs_instance_name  = var.nextjs_instance_name
  springboot_instance_name = var.springboot_instance_name
  tags                  = {
    "environment" = "dev"
    "team"        = "leafresh"
  }
}

module "sql" {
  source = "./modules/sql"

  project_id            = var.project_id
  region                = var.region
  private_db_subnet_id  = module.network.private_db_subnet_id
  mysql_instance_name   = var.mysql_instance_name
  tags                  = {
    "environment" = "dev"
    "team"        = "leafresh"
  }
}

module "redis" {
  source = "./modules/redis"

  project_id            = var.project_id
  region                = var.region
  zone                  = var.zone
  private_db_subnet_id  = module.network.private_db_subnet_id
  redis_instance_name   = var.redis_instance_name
  tags                  = {
    "environment" = "dev"
    "team"        = "leafresh"
  }
}

# GCS 버킷 접근 권한 설정 (SpringBoot 인스턴스에 서비스 계정 연결 필요)
resource "google_project_iam_member" "springboot_gcs_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer" # 필요에 따라 역할 변경
  member  = "serviceAccount:${google_compute_instance.springboot.service_account.0.email}"
  condition {
    title = "gcs-bucket-access"
    expression = "resource.name == 'projects/_/buckets/${var.gcs_bucket_name}'"
  }
}

# Cloud DNS 레코드 생성 (Next.js 인스턴스 IP와 연결)
resource "google_dns_managed_zone" "dns_zone" {
  name        = var.cloud_dns_zone_name
  dns_name    = "${var.cloud_dns_zone_name}."
  project     = var.project_id
  visibility  = "public"
}

resource "google_dns_record_set" "frontend_dns" {
  name         = var.cloud_dns_zone_name
  managed_zone = google_dns_managed_zone.dns_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [module.compute.nextjs_instance_ip]
}

output "nextjs_public_ip" {
  value = module.compute.nextjs_instance_ip
}

output "springboot_private_ip" {
  value = module.compute.springboot_instance_private_ip
}

output "mysql_private_ip" {
  value = module.sql.mysql_private_ip
}

output "redis_private_ip" {
  value = module.redis.redis_private_ip
}

output "redis_port" {
  value = module.redis.redis_port
}
