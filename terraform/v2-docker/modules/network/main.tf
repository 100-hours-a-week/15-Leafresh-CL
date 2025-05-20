# modules/network/main.tf

resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = "leafresh-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "nextjs_public_subnet" {
  project       = var.project_id
  name          = "leafresh-public-subnet-fe"
  ip_cidr_range = var.nextjs_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "springboot_private_subnet" {
  project       = var.project_id
  name          = "leafresh-private-subnet-be"
  ip_cidr_range = var.springboot_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.self_link
}

resource "google_compute_subnetwork" "db_private_subnet" {
  project       = var.project_id
  name          = "leafresh-private-subnet-db"
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.self_link
}
