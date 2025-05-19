# VPC 네트워크 생성
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
  routing_mode            = "REGIONAL"
  mtu                     = 1460
  tags                    = var.tags
}

# Public Subnet 생성
resource "google_compute_subnetwork" "public" {
  name          = var.public_subnet_name
  ip_cidr_range = var.public_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
  private_ip_google_access = false
  tags          = merge(var.tags, {"tier" : "public"})
}

# Private Subnet (App) 생성
resource "google_compute_subnetwork" "private_app" {
  name          = var.private_app_subnet_name
  ip_cidr_range = var.private_app_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
  private_ip_google_access = true
  tags          = merge(var.tags, {"tier" : "private-app"})
}

# Private Subnet (DB) 생성
resource "google_compute_subnetwork" "private_db" {
  name          = var.private_db_subnet_name
  ip_cidr_range = var.private_db_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  project       = var.project_id
  private_ip_google_access = false
  tags          = merge(var.tags, {"tier" : "private-db"})
}

# 기존 GPU 인스턴스 VPC와 VPC 피어링
resource "google_compute_network_peering" "peering_gpu_to_main" {
  name         = "peering-gpu-to-${var.vpc_name}"
  network      = google_compute_network.vpc.id
  peer_network = "projects/${var.project_id}/global/networks/${var.existing_gpu_vpc_network}"
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "peering_main_to_gpu" {
  name         = "peering-${var.vpc_name}-to-gpu"
  network      = "projects/${var.project_id}/global/networks/${var.existing_gpu_vpc_network}"
  peer_network = google_compute_network.vpc.id
  export_custom_routes = true
  import_custom_routes = true
}

# SpringBoot Private Subnet에 대한 기존 GPU VPC 서브넷으로의 라우팅 (피어링된 VPC 간 통신 허용)
resource "google_compute_route" "route_gpu_to_private_app" {
  name        = "route-gpu-to-${var.private_app_subnet_name}"
  dest_range  = var.private_app_subnet_cidr
  network     = "projects/${var.project_id}/global/networks/${var.existing_gpu_vpc_network}"
  next_hop_ip = null
  next_hop_network = google_compute_network.vpc.id
  priority    = 1000
}

resource "google_compute_route" "route_private_app_to_gpu" {
  count       = length(var.existing_gpu_vpc_cidrs)
  name        = "route-${var.private_app_subnet_name}-to-gpu-${count.index}"
  dest_range  = element(var.existing_gpu_vpc_cidrs, count.index)
  network     = google_compute_network.vpc.id
  next_hop_ip = null
  next_hop_network = "projects/${var.project_id}/global/networks/${var.existing_gpu_vpc_network}"
  priority    = 1000
}

output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "public_subnet_id" {
  value = google_compute_subnetwork.public.id
}

output "private_app_subnet_id" {
  value = google_compute_subnetwork.private_app.id
}

output "private_db_subnet_id" {
  value = google_compute_subnetwork.private_db.id
}
