# modules/compute/main.tf

# Next.js GCE 인스턴스
resource "google_compute_instance" "nextjs_instance" {
  project      = var.project_id
  name         = "leafresh-gce-fe"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = [var.nextjs_tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      disk_size_gb = 25 
    }
  }

  network_interface {
    subnetwork = var.nextjs_subnet_self_link
    access_config { # Public Subnet이므로 외부 IP 부여
      // Ephemeral IP, 빈칸일 시 자동으로 IP 부여됨
    }
  }

  metadata = {
    "gce-container-declaration" = <<EOT
spec:
  containers:
    - name: nextjs
      image: ${var.nextjs_docker_image}
      stdin: false
      tty: false
      ports:
        - containerPort: 3000 # Next.js 기본 포트
          hostPort: 80
        - containerPort: 3000
          hostPort: 443
  restartPolicy: Always
EOT
  }

  service_account {
    scopes = ["cloud-platform"] # 필요한 권한 부여 (예: GCR 접근)
  }
}

# Spring Boot GCE 인스턴스
resource "google_compute_instance" "springboot_instance" {
  project      = var.project_id
  name         = "leafresh-gce-be"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = [var.springboot_tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      disk_size_gb = 25
    }
  }

  network_interface {
    subnetwork = var.springboot_subnet_self_link
    # Private Subnet이므로 외부 IP 부여 안함
  }

  metadata = {
    "gce-container-declaration" = <<EOT
spec:
  containers:
    - name: springboot
      image: ${var.springboot_docker_image}
      stdin: false
      tty: false
      ports:
        - containerPort: 8080 # Spring Boot 기본 포트 (예시)
  restartPolicy: Always
EOT
  }

  service_account {
    scopes = [
      "cloud-platform", # GCS 및 다른 GCP 서비스 접근 권한
      "https://www.googleapis.com/auth/devstorage.read_only", # GCS 읽기 권한 예시
      "https://www.googleapis.com/auth/dns.read_only", # Cloud DNS 읽기 권한 예시
    ]
  }
}

# MySQL 및 Redis GCE 인스턴스 (하나의 인스턴스에서 실행)
resource "google_compute_instance" "db_instance" {
  project      = var.project_id
  name         = "leafresh-gce-db"
  machine_type = "e2-medium"
  zone         = var.zone
  tags         = [var.db_tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      disk_size_gb = 50
    }
  }

  network_interface {
    subnetwork = var.db_subnet_self_link
  }

  metadata_startup_script = <<-EOF
#!/bin/bash
apt-get update
apt-get install -y docker.io

# Redis 컨테이너 실행
docker run -d --name redis-server -p 6379:6379 redis-stack:latest

# MySQL 컨테이너 실행
docker run -d --name mysql-server \
-e MYSQL_ROOT_PASSWORD=${var.mysql_root_password} \
-e MYSQL_DATABASE=${var.mysql_database} \
-p 3306:3306 \
mysql:8.0
EOF

  service_account {
    scopes = ["cloud-platform"] # 필요한 권한 부여
  }
}

# Cloud DNS A 레코드 추가 (Next.js 인스턴스 외부 IP를 가리키도록)
resource "google_dns_record_set" "nextjs_dns_record" {
  project      = var.project_id
  managed_zone = var.cloud_dns_zone_name
  name         = "${var.cloud_dns_record_name}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_instance.nextjs_instance.network_interface[0].access_config[0].nat_ip]
}
