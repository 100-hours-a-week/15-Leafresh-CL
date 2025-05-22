provider "google" {
    project = var.project_id
    region = var.region
    zone = var.zone
}

resource "google_compute_instance" "leafresh_gce_db"{
    name = var.instance_name
    machine_type = var.machine_type
    zone = var.zone

    boot_disk{
        initialize_params{
            image = "ubuntu-os-cloud/ubuntu-2204-lts" 
            size = 30
        }
    }

    network_interface {
        network = var.network
        subnetwork = var.subnetwork
    }

    metadata_startup_script = <<-EOF
#!/bin/bash
apt-get update
apt-get install -y docker.io

# Redis 컨테이너 실행
docker run -d --name redis-server -p 6379:6379 redis:latest

# MySQL 컨테이너 실행
docker run -d --name mysql-server \
-e MYSQL_ROOT_PASSWORD=${var.mysql_root_password} \
-e MYSQL_DATABASE=${var.mysql_database} \
-p 3306:3306 \
mysql:8.0
EOF

    tags = ["leafresh-db"]

    service_account {
        email = var.service_account_email
        scopes = ["cloud-platform"]
    }
}

resource "google_compute_firewall" "allow_db_ports"{
    name = "leafresh-db-ports"
    network = var.network

    allow {
        protocol = "tcp"
        ports = ["3306", "6379"]
    }

    target_tags = ["leafresh-db"]
    direction = "INGRESS"
    source_tags = ["leafresh-be"]  
}