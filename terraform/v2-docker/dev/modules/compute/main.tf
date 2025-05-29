# modules/compute/main.tf

# 템플릿 로컬 적용
locals {
  docker_compose = templatefile("${path.module}/nginx/docker-compose.tpl", {
    image          = var.startup_fe_image
    container_name = var.startup_fe_container_name
    port           = var.startup_fe_nextjs_port
  })

  nginx_conf = templatefile("${path.module}/nginx/default.conf.tpl", {
    domain = var.dns_record_name
  })

  fe_startup_script = templatefile("${path.module}/fe_startup.sh.tpl", {
    domain           = var.dns_record_name
    docker_compose   = local.docker_compose
    nginx_conf       = local.nginx_conf
  })

  be_startup_script = templatefile("${path.module}/be_startup.sh.tpl", {
    port           = var.startup_be_springboot_port
    secret_name    = var.startup_be_secret_name 
    container_name = var.startup_be_container_name 
    image          = var.startup_be_image
  })

  db_startup_script = templatefile("${path.module}/db_startup.sh.tpl", {
    mysql_root_password = var.startup_db_mysql_root_password 
    mysql_database      = var.startup_db_mysql_database_name 
    redis_port          = var.startup_db_redis_port
    redis_host          = var.startup_db_redis_host
  })
}


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

  metadata_startup_script = local.fe_startup_script

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

  metadata_startup_script = local.fe_startup_script

  service_account {
    scopes = ["cloud-platform"]
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

  metadata_startup_script = local.db_startup_script

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
