# modules/compute/main.tf

# Next.js GCE 인스턴스
resource "google_compute_instance" "nextjs_instance" {
  project      = var.project_id
  name         = "leafresh-gce-fe"
  machine_type = "e2-medium" # 적절한 머신 타입 선택
  zone         = var.zone
  tags         = [var.nextjs_tag]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable" # COS 이미지 사용
      disk_size_gb = 25 
    }
  }

  network_interface {
    subnetwork = var.nextjs_subnet_self_link
    access_config { # Public Subnet이므로 외부 IP 부여
      // Ephemeral IP
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
  machine_type = "e2-medium" # 적절한 머신 타입 선택
  zone         = var.zone
  tags         = [var.springboot_tag]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable" # COS 이미지 사용
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
      image = "cos-cloud/cos-stable" # COS 이미지 사용
      disk_size_gb = 50
    }
  }

  network_interface {
    subnetwork = var.db_subnet_self_link
  }

  metadata = {
    "gce-container-declaration" = <<EOT
spec:
  containers:
    - name: mysql
      image: ${var.mysql_docker_image}
      stdin: false
      tty: false
      env:
        - name: MYSQL_ROOT_PASSWORD
          value: "your_mysql_root_password" # 실제 비밀번호로 변경! Secret Manager 사용 권장
      ports:
        - containerPort: 3306
    - name: redis
      image: ${var.redis_docker_image}
      stdin: false
      tty: false
      ports:
        - containerPort: 6379
  restartPolicy: Always
EOT
  }

  service_account {
    scopes = ["cloud-platform"] # 필요한 권한 부여
  }
}

# Cloud DNS A 레코드 추가 (Next.js 인스턴스 외부 IP를 가리키도록)
resource "google_dns_record_set" "nextjs_dns_record" {
  project      = var.project_id
  managed_zone = var.cloud_dns_zone_name # 기존 Cloud DNS Zone 이름
  name         = "${var.cloud_dns_record_name}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_instance.nextjs_instance.network_interface[0].access_config[0].nat_ip]
}
