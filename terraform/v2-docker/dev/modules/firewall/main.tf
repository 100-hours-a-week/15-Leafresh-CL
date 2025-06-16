# modules/firewall/main.tf

# fe 인스턴스 외부 접근 허용 (80, 443, 22)
resource "google_compute_firewall" "allow_fe_from_internet" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-fe-from-internet"
  network     = var.vpc_name
  target_tags = [var.tag_fe] ### target이 기준이다

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

# be 인스턴스 외부 접근 허용 (80, 443, 22)
resource "google_compute_firewall" "allow_be_from_internet" {
  project = var.project_id_dev
  name    = "leafresh-firewall-be-from-internet"
  network = var.vpc_name
  target_tags = [var.tag_be]

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  allow {
    protocol = "icmp"
  }
  
  source_ranges = ["0.0.0.0/0"]
}

# DB 인스턴스 외부 접근 허용 (22, 3306, 6379)
#resource "google_compute_firewall" "allow_db_from_internet" {
#  project = var.project_id_dev
#  name    = "leafresh-firewall-db-from-internet"
#  network = var.vpc_name
#  target_tags = [var.tag_db]
#
#  allow {
#    protocol = "tcp"
#    ports    = ["22", "3306", "6379"]
#  }
#  allow {
#    protocol = "icmp"
#  }
#  
#  source_ranges = ["0.0.0.0/0"]
#}

# fe -> be 통신 허용
resource "google_compute_firewall" "allow_fe_to_be" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-fe-to-be"
  network     = var.vpc_name
  target_tags = [var.tag_be]
  source_tags = [var.tag_fe]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }
  allow {
    protocol = "icmp"
  }
}

# be -> fe 통신 허용
resource "google_compute_firewall" "allow_be_to_fe" {
  project     = var.project_id_dev
  name        = "leafresh-firewall-be-to-fe"
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


# be -> MySQL/Redis 통신 허용
#resource "google_compute_firewall" "allow_be_to_db" {
#  project     = var.project_id_dev
#  name        = "leafresh-firewall-be-to-db"
#  network     = var.vpc_name
#  target_tags = [var.tag_db]
#  source_tags = [var.tag_be]
#
#  allow {
#    protocol = "tcp"
#    ports    = ["3306", "6379"]
#  }
#  allow {
#    protocol = "icmp"
#  }
#}

# MySQL/Redis -> be 통신 허용 (DB 응답)
#resource "google_compute_firewall" "allow_db_to_be" {
#  project     = var.project_id_dev
#  name        = "leafresh-firewall-db-to-be"
#  network     = var.vpc_name
#  target_tags = [var.tag_be]
#  source_tags = [var.tag_db]
#
#  allow {
#    protocol = "tcp"
#    ports    = ["8080"]
#  }
#  allow {
#    protocol = "icmp"
#  }
#}

# be <-> GPU instance VPC 통신 허용
# 기존 GPU VPC에 대한 정보가 없으므로, 해당 VPC의 CIDR 범위를 source_ranges로 사용
resource "google_compute_firewall" "allow_be_to_gpu1" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-be-to-gpu1"
  network       = var.vpc_name
  target_tags   = [var.vpc_cidr_block_gpu1]
  source_ranges = [var.tag_be]

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_gpu1_to_be" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-gpu1-to-be"
  network       = var.vpc_name
  target_tags   = [var.tag_be]
  source_ranges = [var.vpc_cidr_block_gpu1]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_be_to_gpu2" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-be-to-gpu2"
  network       = var.vpc_name
  target_tags   = [var.vpc_cidr_block_gpu2]
  source_ranges = [var.tag_be]

  allow {
    protocol = "tcp"
    ports    = ["8000"]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_gpu2_to_be" {
  project       = var.project_id_dev
  name          = "leafresh-firewall-gpu2-to-be"
  network       = var.vpc_name
  target_tags   = [var.tag_be]
  source_ranges = [var.vpc_cidr_block_gpu2]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
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
  target_tags = [var.tag_fe, var.tag_be] # , var.tag_db]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IP range that IAP uses.
  source_ranges = ["35.235.240.0/20"]
  description   = "Allow SSH access through IAP to private instances."
}

