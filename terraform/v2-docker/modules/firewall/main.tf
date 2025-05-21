# modules/firewall/main.tf

# Next.js 인스턴스 외부 접근 허용 (80, 443, 22)
resource "google_compute_firewall" "allow_nextjs_external" {
  project = var.project_id
  name    = "leafresh-firewall-fe-to-external"
  network = var.network_name
  target_tags = [var.nextjs_tag]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Next.js -> Spring Boot 통신 허용
resource "google_compute_firewall" "allow_nextjs_to_springboot" {
  project = var.project_id
  name    = "leafresh-firewall-nextjs-to-spring"
  network = var.network_name
  target_tags = [var.springboot_tag]
  source_tags = [var.nextjs_tag]

  allow {
    protocol = "tcp"
    ports    = ["8080"] # Spring Boot 포트 (예시)
  }
}

# Spring Boot -> Next.js 통신 허용 (Next.js가 응답할 때)
resource "google_compute_firewall" "allow_springboot_to_nextjs" {
  project = var.project_id
  name    = "leafresh-firewall-spring-to-nextjs"
  network = var.network_name
  target_tags = [var.nextjs_tag]
  source_tags = [var.springboot_tag]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000:"]
  }
}


# Spring Boot -> MySQL/Redis 통신 허용
resource "google_compute_firewall" "allow_springboot_to_db" {
  project = var.project_id
  name    = "leafresh-firewall-spring-to-db"
  network = var.network_name
  target_tags = [var.db_tag]
  source_tags = [var.springboot_tag]

  allow {
    protocol = "tcp"
    ports    = ["3306", "6379"] # MySQL, Redis 포트
  }
}

# MySQL/Redis -> Spring Boot 통신 허용 (DB가 응답할 때)
resource "google_compute_firewall" "allow_db_to_springboot" {
  project = var.project_id
  name    = "leafresh-firewall-db-to-spring"
  network = var.network_name
  target_tags = [var.springboot_tag]
  source_tags = [var.db_tag]

  allow {
    protocol = "tcp"
    ports    = ["8080"] # Spring Boot 포트 (예시)
  }
}

# Spring Boot <-> GPU instance VPC 통신 허용
# 기존 GPU VPC에 대한 정보가 없으므로, 해당 VPC의 CIDR 범위를 source_ranges로 사용
resource "google_compute_firewall" "allow_springboot_to_gpu1" {
  project = var.project_id
  name    = "leafresh-firewall-spring-to-gpu1"
  network = var.network_name
  target_tags = [var.springboot_tag]
  source_ranges = var.gpu1_instance_vpc_cidr_blocks

  allow {
    protocol = "tcp"
    ports    = ["8000"] # 필요한 포트로 제한
  }
}

resource "google_compute_firewall" "allow_gpu1_to_springboot" {
  project = var.project_id
  name    = "leafresh-firewall-gpu1-to-spring"
  network = var.network_name
  target_tags = [var.springboot_tag]
  source_ranges = var.gpu1_instance_vpc_cidr_blocks

  allow {
    protocol = "tcp"
    ports    = ["8080"] # 필요한 포트로 제한
  }
}

resource "google_compute_firewall" "allow_springboot_to_gpu2" {
  project = var.project_id
  name    = "leafresh-firewall-spring-to-gpu2"
  network = var.network_name
  target_tags = [var.springboot_tag]
  source_ranges = var.gpu2_instance_vpc_cidr_blocks

  allow {
    protocol = "tcp"
    ports    = ["8000"] # 필요한 포트로 제한
  }
}

resource "google_compute_firewall" "allow_gpu2_to_springboot" {
  project = var.project_id
  name    = "leafresh-firewall-gpu2-to-spring"
  network = var.network_name
  target_tags = [var.springboot_tag]
  source_ranges = var.gpu2_instance_vpc_cidr_blocks

  allow {
    protocol = "tcp"
    ports    = ["8080"] # 필요한 포트로 제한
  }
# SSH 접속 허용 (모든 인스턴스)
resource "google_compute_firewall" "allow_ssh" {
  project = var.project_id
  name    = "allow-ssh"
  network = var.network_name
  target_tags = [var.nextjs_tag, var.springboot_tag, var.db_tag]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # 특정 IP로 제한하는 것이 좋음
}
