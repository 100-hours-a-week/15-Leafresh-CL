# modules/firewall/main.tf

# Next.js 인스턴스 외부 접근 허용 (80, 443, 22)
resource "google_compute_firewall" "allow_nextjs_external" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-fe-to-external"
  network     = var.vpc_name
  target_tags = [var.tag_fe]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Next.js -> Spring Boot 통신 허용
resource "google_compute_firewall" "allow_nextjs_to_springboot" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-nextjs-to-spring"
  network     = var.vpc_name
  target_tags = [var.tag_be]
  source_tags = [var.tag_fe]

  allow {
    protocol = "tcp"
    ports    = ["8080"] # Spring Boot 포트 (예시)
  }
  allow {
    protocol = "icmp"
  }
}

# Spring Boot -> Next.js 통신 허용 (Next.js가 응답할 때)
resource "google_compute_firewall" "allow_springboot_to_nextjs" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-spring-to-nextjs"
  network     = var.vpc_name
  target_tags = [var.tag_fe]
  source_tags = [var.tag_be]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000"]
  }
  allow {
    protocol = "icmp"
  }
}


# Spring Boot -> MySQL/Redis 통신 허용
resource "google_compute_firewall" "allow_springboot_to_db" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-spring-to-db"
  network     = var.vpc_name
  target_tags = [var.tag_db]
  source_tags = [var.tag_be]

  allow {
    protocol = "tcp"
    ports    = ["3306", "6379"] # MySQL, Redis 포트
  }
  allow {
    protocol = "icmp"
  }
}

# MySQL/Redis -> Spring Boot 통신 허용 (DB가 응답할 때)
resource "google_compute_firewall" "allow_db_to_springboot" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-db-to-spring"
  network     = var.vpc_name
  target_tags = [var.tag_be]
  source_tags = [var.tag_db]

  allow {
    protocol = "tcp"
    ports    = ["8080"] # Spring Boot 포트 (예시)
  }
  allow {
    protocol = "icmp"
  }
}

# Spring Boot <-> GPU instance VPC 통신 허용
# 기존 GPU VPC에 대한 정보가 없으므로, 해당 VPC의 CIDR 범위를 source_ranges로 사용
resource "google_compute_firewall" "allow_springboot_to_gpu1" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-spring-to-gpu1"
  network       = var.vpc_name
  target_tags   = [var.tag_be]
  source_ranges = [var.vpc_cidr_block_gpu1]

  allow {
    protocol = "tcp"
    ports    = ["8000"] # 필요한 포트로 제한
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_gpu1_to_springboot" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-gpu1-to-spring"
  network       = var.vpc_name
  target_tags   = [var.tag_be]
  source_ranges = [var.vpc_cidr_block_gpu1]

  allow {
    protocol = "tcp"
    ports    = ["8080"] # 필요한 포트로 제한
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_springboot_to_gpu2" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-spring-to-gpu2"
  network       = var.vpc_name
  target_tags   = [var.tag_be]
  source_ranges = [var.vpc_cidr_block_gpu2]

  allow {
    protocol = "tcp"
    ports    = ["8000"] # 필요한 포트로 제한
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_gpu2_to_springboot" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-gpu2-to-spring"
  network       = var.vpc_name
  target_tags   = [var.tag_be]
  source_ranges = [var.vpc_cidr_block_gpu2]

  allow {
    protocol = "tcp"
    ports    = ["8080"] # 필요한 포트로 제한
  }
  allow {
    protocol = "icmp"
  }
}

# IAP를 통한 SSH 접속 허용
resource "google_compute_firewall" "allow_iap_ssh" {
  project = var.project_id_dev
  name    = "allow-iap-ssh"
  network = var.vpc_name
  # Spring Boot 및 DB 인스턴스에만 IAP 적용
  target_tags = [var.tag_fe, var.tag_be, var.tag_db]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP가 사용하는 IP 주소 범위
  source_ranges = ["35.235.240.0/20"]
  description   = "Allow SSH access through IAP to private instances."
}
