# modules/compute/main.tf

# Next.js GCE 인스턴스
resource "google_compute_instance" "nextjs_instance" {
  project      = var.project_id
  name         = "leafresh-gce-fe"
  machine_type = "e2-custom-1-3072"
  zone         = var.zone
  tags         = [var.nextjs_tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 25 
    }
  }

  network_interface {
    subnetwork = var.nextjs_subnet_self_link
    access_config { # Public Subnet이므로 외부 IP 부여
      // Ephemeral IP, 빈칸일 시 자동으로 IP 부여됨
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

# Docker Hub에서 이미지 다운로드 및 실행
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
resource "google_compute_instance" "springboot_instance" {
  project      = var.project_id
  name         = "leafresh-gce-be"
  machine_type = "e2-custom-1-3072"
  zone         = var.zone
  tags         = [var.springboot_tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 25
    }
  }

  network_interface {
    subnetwork = var.springboot_subnet_self_link
    access_config {}
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

# Docker Hub에서 이미지 다운로드 및 실행
sudo docker run -d \
  --name springboot-backend \
  -p 8080:8080 \
  jchanho99/backend-dev:latest
EOF

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_write"
    ]
  }
}

# MySQL 및 Redis GCE 인스턴스 (하나의 인스턴스에서 실행)
resource "google_compute_instance" "db_instance" {
  project      = var.project_id
  name         = "leafresh-gce-db"
  machine_type = "e2-custom-1-3072"
  zone         = var.zone
  tags         = [var.db_tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size = 50
    }
  }

  network_interface {
    subnetwork = var.db_subnet_self_link
  }

  metadata_startup_script = <<-EOF
#!/bin/bash

# Docker 설치 (더 상세하고 공식 권장 방식)
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo ufw allow 6379/tcp
sudo ufw allow 8001/tcp
sudo ufw allow 22/tcp
echo "y" | sudo ufw enable

# docker-compose.yml 파일 생성
cat << 'EOT' > /home/ubuntu/docker-compose.yml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: leafresh-mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: ${var.mysql_root_password}
      MYSQL_DATABASE: ${var.mysql_database} 
      MYSQL_USER: ${var.db_user} 
      MYSQL_PASSWORD: ${var.db_user_password} 
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql # 데이터 영속성을 위한 볼륨
    networks:
      - internal_network # 내부 통신용 네트워크

  redis:
    image: redislabs/rebloom:2.8.1
    container_name: leafresh-redis
    restart: always
    ports:
      - "6379:6379"
      - "8001:8001"
    volumes:
      - redis_data:/data
    networks:
      - internal_network # 내부 통신용 네트워크

volumes:
  mysql_data:
  redis_data:

networks:
  internal_network:
    driver: bridge # Docker 내부 네트워크
EOT

# Docker Compose 실행
sudo docker compose -f /home/ubuntu/docker-compose.yml up -d
EOF

  service_account {
    scopes = ["cloud-platform"] # 필요한 권한 부여
  }
}

# Cloud DNS A 레코드 추가 (Next.js 인스턴스 외부 IP를 가리키도록)
resource "google_dns_record_set" "nextjs_dns_record" {
  project      = "leafresh"
  managed_zone = var.cloud_dns_zone_name
  name         = "${var.cloud_dns_record_name}."
  type         = "A"
  ttl          = 18000
  rrdatas      = [google_compute_instance.nextjs_instance.network_interface[0].access_config[0].nat_ip]
}
