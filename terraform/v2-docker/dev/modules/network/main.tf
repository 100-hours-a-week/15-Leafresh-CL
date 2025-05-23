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

# Cloud NAT IP 주소 예약 (NAT Gateway가 사용할 고정 외부 IP)
resource "google_compute_address" "nat_ip" {
  project      = var.project_id
  name         = "nat-ip-address"
  region       = var.region
  address_type = "EXTERNAL"
}

# Cloud NAT Gateway 생성
resource "google_compute_router" "nat_router" {
  project = var.project_id
  name    = "nat-router"
  region  = var.region
  network = google_compute_network.vpc.self_link # 생성한 VPC에 연결
}

resource "google_compute_router_nat" "nat_gateway" {
  project                          = var.project_id
  name                             = "nat-gateway"
  router                           = google_compute_router.nat_router.name
  region                           = google_compute_router.nat_router.region
  nat_ip_allocate_option           = "MANUAL_ONLY" # 고정 IP 사용
  nat_ips                          = [google_compute_address.nat_ip.self_link]

  # NAT를 적용할 서브넷 지정
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.springboot_private_subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"] # 해당 서브넷의 모든 IP 범위 NAT 적용
  }
  subnetwork {
    name                    = google_compute_subnetwork.db_private_subnet.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"] # 해당 서브넷의 모든 IP 범위 NAT 적용
  }
  # Private Google Access가 필요하지 않은 경우, "NO_PUBLIC_IPS" 옵션도 고려할 수 있습니다.
  # 하지만 일반적인 외부 통신에는 "ALL_IP_RANGES"가 더 유연합니다.
}
