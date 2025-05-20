# modules/network/main.tf

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "three-tier-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "nextjs_public_subnet" {
  project       = var.project_id
  name          = "nextjs-public-subnet"
  ip_cidr_range = var.nextjs_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "springboot_private_subnet" {
  project       = var.project_id
  name          = "springboot-private-subnet"
  ip_cidr_range = var.springboot_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "db_private_subnet" {
  project       = var.project_id
  name          = "db-private-subnet"
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.self_link
}

output "vpc_name" {
  description = "생성된 VPC의 이름"
  value       = google_compute_network.vpc.name
}

output "nextjs_subnet_self_link" {
  description = "Next.js Public Subnet의 Self Link"
  value       = google_compute_subnetwork.nextjs_public_subnet.self_link
}

output "springboot_subnet_self_link" {
  description = "Spring Boot Private Subnet의 Self Link"
  value       = google_compute_subnetwork.springboot_private_subnet.self_link
}

output "db_subnet_self_link" {
  description = "MySQL/Redis Private Subnet의 Self Link"
  value       = google_compute_subnetwork.db_private_subnet.self_link
}
