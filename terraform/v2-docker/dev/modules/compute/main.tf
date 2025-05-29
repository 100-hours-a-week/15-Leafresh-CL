# modules/compute/main.tf

# Next.js GCE 인스턴스
resource "google_compute_instance" "fe_instance" {
  project      = var.project_id_dev
  name         = var.gce_name_fe
  machine_type = var.gce_machine_type_fe
  zone         = var.zone
  tags         = [var.tag_fe]

  boot_disk {
    initialize_params {
      image = var.gce_image
      size  = var.gce_disk_size
    }
  }

  network_interface {
    subnetwork = var.subnet_fe_self_link
    network_ip = var.static_internal_ip_fe
    access_config {
      nat_ip = var.static_ip_fe
    }
  }

  metadata_startup_script = <<-EOF
#!/bin/bash

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 3000/tcp
sudo ufw allow 22/tcp
echo "y" | sudo ufw enable

# Docker 설치
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 사용자 그룹에 현재 사용자 추가 (선택 사항, 필요 시)
# sudo usermod -aG docker ubuntu 

sudo docker run -d \
  --name nextjs-frontend \
  -p 80:3000 \
  -p 443:3000 \
  -p 3000:3000 \
  jchanho99/frontend-dev:latest
EOF

  service_account {
    scopes = ["cloud-platform"] # 전체 권한 부여 기능, 수정 필요 
  }
}


# Spring Boot GCE 인스턴스
resource "google_compute_instance" "be_instance" {
  project      = var.project_id_dev
  name         = var.gce_name_be
  machine_type = var.gce_machine_type_be
  zone         = var.zone
  tags         = [var.tag_be]

  boot_disk {
    initialize_params {
      image = var.gce_image
      size  = var.gce_disk_size
    }
  }

  network_interface {
    subnetwork = var.subnet_be_self_link
    network_ip = var.static_internal_ip_be
    access_config {
      nat_ip = var.static_ip_be
    }
  }


  metadata_startup_script = <<-EOF
#!/bin/bash

sudo ufw allow 8080/tcp
sudo ufw allow 22/tcp
echo "y" | sudo ufw enable

# Docker 설치
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker 사용자 그룹에 현재 사용자 추가 (선택 사항, 필요 시)
# sudo usermod -aG docker ubuntu 

# Secret Manager에서 .env 가져오기
gcloud secrets versions access latest --secret="=env-be-local" > /etc/app/.env

# 환경 변수 적용
export $(cat /etc/app/.env | xargs)

# Docker Hub에서 이미지 다운로드 및 실행
sudo docker run -d \
  --name springboot-backend \
  -p 8080:8080 \
  -env-file .env \
  jchanho99/backend-dev:latest
EOF

  service_account {
    scopes = [
      "cloud-platform"
    ]
  }
}

# MySQL 및 Redis GCE 인스턴스 (하나의 인스턴스에서 실행)
resource "google_compute_instance" "db_instance" {
  project      = var.project_id_dev
  name         = var.gce_name_db
  machine_type = var.gce_machine_type_db
  zone         = var.zone
  tags         = [var.tag_db]

  boot_disk {
    initialize_params {
      image = var.gce_image
      size  = var.gce_disk_size + 25
    }
  }

  network_interface {
    subnetwork = var.subnet_db_self_link
    network_ip = var.static_internal_ip_db
  }

  metadata_startup_script = templatefile("${path.module}/db_startup.sh.tpl", {
    mysql_root_password = "Rlatldms!2!3"
    mysql_database      = "leafresh"
    redis_port          = "6379"
    redis_host          = "localhost"
  })

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Cloud DNS A 레코드 추가 (Next.js 인스턴스 외부 IP를 가리키도록)
resource "google_dns_record_set" "nextjs_dns_record" {
  project      = "leafresh"
  managed_zone = var.dns_zone_name
  name         = "${var.dns_record_name}."
  type         = "A"
  ttl          = 18000
  rrdatas      = [google_compute_instance.fe_instance.network_interface[0].access_config[0].nat_ip]
}
