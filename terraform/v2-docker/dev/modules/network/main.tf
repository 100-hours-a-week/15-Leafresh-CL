# modules/network/main.tf

locals {
  merged_labels = merge({}, {
    purpose = "communication"
    role    = "subnet"
  })
}


# Subnet 정의
resource "google_compute_subnetwork" "public_fe" {
  project       = var.project_id
  name          = var.subnet_name_fe
  ip_cidr_range = var.subnet_cidr_fe
  region        = var.region
  network       = var.vpc_self_link
}

resource "google_compute_subnetwork" "public_be" {
  project       = var.project_id
  name          = var.subnet_name_be
  ip_cidr_range = var.subnet_cidr_be
  region        = var.region
  network       = var.vpc_self_link
}

resource "google_compute_subnetwork" "public_vault" {
  project       = var.project_id
  name          = var.subnet_name_vault
  ip_cidr_range = var.subnet_cidr_vault
  region        = var.region
  network       = var.vpc_self_link
}

resource "google_compute_subnetwork" "private_db" {
  project       = var.project_id
  name          = var.subnet_name_db
  ip_cidr_range = var.subnet_cidr_db
  region        = var.region
  network       = var.vpc_self_link
}


# NAT Gateway 정의
# resource "google_compute_address" "nat_ip" {
#   project      = var.project_id_dev
#   name         = var.nat_ip
#   region       = var.region
#   address_type = "EXTERNAL"
#
#   labels = {
#     purpose = "nat-ip"
#     env     = "dev"
#   }
# }

# resource "google_compute_router" "nat_router" {
#   project = var.project_id_dev
#   name    = var.nat_router
#   region  = var.region
#   network = var.vpc_self_link
# }

# resource "google_compute_router_nat" "nat_gateway" {
#   project                = var.project_id_dev
#   name                   = var.nat_gateway
#   router                 = google_compute_router.nat_router.name
#   region                 = google_compute_router.nat_router.region
#   nat_ip_allocate_option = "MANUAL_ONLY" # 고정 IP 사용
#   nat_ips                = [google_compute_address.nat_ip.self_link]
#
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
#   subnetwork {
#     name                    = google_compute_subnetwork.private_subnet_be.self_link
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"] # 해당 서브넷의 모든 IP 범위 NAT 적용
#   }
#   subnetwork {
#     name                    = google_compute_subnetwork.private_subnet_db.self_link
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"] # 해당 서브넷의 모든 IP 범위 NAT 적용
#   }
# }

# FE 외부 IP 부여
resource "google_compute_address" "static_ip_fe" {
  name    = var.static_ip_name_fe
  region  = var.region
  project = var.project_id

  labels = local.merged_labels

  # address = "34.47.75.62"
}

# BE 외부 IP 부여
resource "google_compute_address" "static_ip_be" {
  name    = var.static_ip_name_be
  region  = var.region
  project = var.project_id

  labels = local.merged_labels

  # address = "34.64.183.21"
}

resource "google_compute_address" "static_ip_vault" {
  name    = var.static_ip_name_vault
  region  = var.region
  project = var.project_id

  labels = local.merged_labels

  # address = "34.64.183.21"
}

# DB 외부 IP 부여
#resource "google_compute_address" "static_ip_db" {
#  name    = var.static_ip_name_db
#  region  = var.region
#  project = var.project_id_dev
#
#  labels = {
#    role = "db"
#    env  = "dev"
#  }
#
#  # address = "34.64.134.224"
#}


# VPC Peering 정의
resource "google_compute_network_peering" "dev-to-gpu1" {
  name         = "leafresh-peering-dev-to-gpu1"
  network      = "projects/${var.project_id}/global/networks/${var.vpc_name_dev}"
  peer_network = "projects/${var.project_id_gpu1}/global/networks/${var.vpc_name_gpu1}"

  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "gpu1-to-dev" {
  name         = "leafresh-peering-gpu1-to-dev"
  network      = "projects/${var.project_id_gpu1}/global/networks/${var.vpc_name_gpu1}"
  peer_network = "projects/${var.project_id}/global/networks/${var.vpc_name_dev}"

  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "dev-to-gpu2" {
  name         = "leafresh-peering-dev-to-gpu2"
  network      = "projects/${var.project_id}/global/networks/${var.vpc_name_dev}"
  peer_network = "projects/${var.project_id_gpu2}/global/networks/${var.vpc_name_gpu2}"

  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "gpu2-to-dev" {
  name         = "leafresh-peering-gpu2-to-dev"
  network      = "projects/${var.project_id_gpu2}/global/networks/${var.vpc_name_gpu2}"
  peer_network = "projects/${var.project_id}/global/networks/${var.vpc_name_dev}"

  export_custom_routes = true
  import_custom_routes = true
}
