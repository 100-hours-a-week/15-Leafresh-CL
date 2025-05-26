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
apt update
# Node.js 22 설치 (NodeSource 공식 설치 스크립트)
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
apt install -y nodejs

git clone --branch v1.0.5 --depth 1 https://github.com/100-hours-a-week/15-Leafresh-FE.git
cd 15-Leafresh-FE
pnpm run install
pnpm run build
pnpm run start
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
      size = 25
    }
  }

  network_interface {
    subnetwork = var.springboot_subnet_self_link
    # Private Subnet이므로 외부 IP 부여 안함
  }

  metadata_startup_script = <<-EOF
#!/bin/bash
apt update
apt install -y openjdk-21-jdk

# JAVA_HOME 설정을 시스템 전체로 적용
JAVA_HOME=$(dirname $(dirname $(readlink -f $(which javac))))
echo "export JAVA_HOME=$JAVA_HOME" > /etc/profile.d/java.sh
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh
chmod +x /etc/profile.d/java.sh

git clone --branch v1.0.0 --depth 1 https://github.com/100-hours-a-week/15-Leafresh-BE.git
cd 15-Leafresh-BE
./gradlew build
./gradlew bootJar &
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
      size = 50
    }
  }

  network_interface {
    subnetwork = var.db_subnet_self_link
  }

metadata_startup_script = templatefile("${path.module}/scripts/db-setup.sh", {
  db_user            = var.db_user,
  db_user_password   = var.db_user_password,
  mysql_root_password = var.mysql_root_password,
  mysql_database     = var.mysql_database
})

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
