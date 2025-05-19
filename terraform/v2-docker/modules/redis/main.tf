resource "google_redis_instance" "redis" {
  name       = var.redis_instance_name
  project    = var.project_id
  region     = var.region
  zone       = var.zone
  tier       = "BASIC" # 필요에 따라 서비스 등급 변경 (STANDARD_HA 권장)
  memory_size_gb = 1     # 필요에 따라 메모리 크기 변경
  network_config {
    network            = "projects/${var.project_id}/global/networks/default" # 기본 네트워크 또는 VPC 이름
    reserved_peering_ip_range = "redis-range" # 고유한 IP 범위 이름
  }
  authorized_network = var.private_db_subnet_id
  display_name       = var.redis_instance_name
  labels             = merge(var.tags, {"tier" : "cache", "app" : "redis"})
}

# Redis 인스턴스를 위한 IP 범위 예약 (Private Service Access 필요)
resource "google_compute_global_address" "redis_ip_range" {
  name          = "redis-reserved-range"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24 # 필요에 따라 조정
  network       = "projects/${var.project_id}/global/networks/default" # 기본 네트워크 또는 VPC 이름
}

# VPC 네트워크와 Redis 서비스 네트워크 간의 비공개 서비스 액세스 연결
resource "google_service_networking_connection" "redis_connection" {
  provider                = google-beta
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.redis_ip_range.name]
}

output "redis_private_ip" {
  value = google_redis_instance.redis.host
}

output "redis_port" {
  value = google_redis_instance.redis.port
}
