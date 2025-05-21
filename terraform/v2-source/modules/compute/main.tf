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

  metadata_startup_script = <<-EOF
#!/bin/bash
apt update
# Node.js 22 설치 (NodeSource 공식 설치 스크립트)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
# 버전 확인
node -v
npm -v
EOF

  service_account {
    scopes = ["cloud-platform"] # 전체 권한 부여 기능, 수정 필요 
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

  metadata_startup_script = <<-EOF
#!/bin/bash
apt update
# Java 21 (OpenJDK) 설치
sudo apt install -y openjdk-21-jdk
# JAVA_HOME 설정 (선택)
echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))" >> ~/.bashrc
echo "export PATH=$JAVA_HOME/bin:$PATH" >> ~/.bashrc
source ~/.bashrc
# 버전 확인
java -version
javac -version
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
# Redis 먼저 가보자
apt-get update
apt-get install -y redis-server
wget https://github.com/RedisBloom/RedisBloom/archive/refs/tags/v2.6.18.tar.gz
tar -xvf v2.6.18.tar.gz
cd RedisBloom-2.6.18/
make
sudo make install
--- redis 설정값 필요 ---
# 이제 MySQL이다
apt-get install -y mysql-server
sudo systemctl start mysql
sudo systemctl enable mysql
--- mysql 설정값 필요 ---
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
