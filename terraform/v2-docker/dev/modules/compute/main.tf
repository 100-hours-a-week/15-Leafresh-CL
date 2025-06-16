# modules/compute/main.tf

# labels 적용
locals {
  common_labels = {
    app         = "leafresh"
    environment = "dev"
    team        = "infra"
  }

  labels_fe = merge(local.common_labels, {
    role = "fe"
  })

  labels_be = merge(local.common_labels, {
    role = "be"
  })

  labels_db = merge(local.common_labels, {
    role = "db"
  })

  block_enabled_fe = true
  env_fe   = "NEXT_PUBLIC_API_URL=https://springboot.${var.dns_record_name}"
  block_fe = local.block_enabled_fe ? (
    <<EOT

    environment:
      - ${local.env_fe}
  EOT
  ) : ""

  block_enabled_be   = true
  env_path_be   = "./app/.env"
  gcp_key_path_be      = "./app/leafresh-gcs.json"
  block_be = local.block_enabled_be ? (
    <<EOT

    env_file:
      - ${local.env_path_be}

    volumes:
      - ${local.gcp_key_path_be}:${local.gcp_key_path_be}:ro
  EOT
  ) : ""
}


# 템플릿 로컬 적용
locals {
  docker_compose_fe = templatefile("${path.module}/nginx/docker-compose.tpl", {
    image          = var.startup_fe_image
    container_name = var.startup_fe_container_name
    port           = var.startup_fe_nextjs_port
    additional_block  = local.block_fe
  })

  docker_compose_be = templatefile("${path.module}/nginx/docker-compose.tpl", {
    image          = var.startup_be_image
    container_name = var.startup_be_container_name
    port           = var.startup_be_springboot_port
    additional_block  = local.block_be
  })


  nginx_conf_fe = templatefile("${path.module}/nginx/default_fe.conf.tpl", {
    domain = var.dns_record_name
    port   = 3000
  })

  nginx_conf_be = templatefile("${path.module}/nginx/default_be.conf.tpl", {
    domain = "springboot.${var.dns_record_name}"
    port   = 8080
  })


  startup_script_fe = templatefile("${path.module}/fe_startup.sh.tpl", {
    domain         = var.dns_record_name
    docker_compose = local.docker_compose_fe
    nginx_conf     = local.nginx_conf_fe
    container_name = var.startup_fe_container_name
  })

  startup_script_be = templatefile("${path.module}/be_startup.sh.tpl", {
    domain         = "springboot.${var.dns_record_name}"
    docker_compose = local.docker_compose_be
    nginx_conf     = local.nginx_conf_be
    port           = var.startup_be_springboot_port
    secret_name    = var.startup_be_secret_name
    secret_name_json = var.startup_be_secret_name_json
    image          = var.startup_be_image
    container_name = var.startup_be_container_name
  })

  startup_script_db = templatefile("${path.module}/db_startup.sh.tpl", {
    mysql_root_password = var.startup_db_mysql_root_password
    mysql_database      = var.startup_db_mysql_database_name
    redis_port          = var.startup_db_redis_port
    redis_host          = var.startup_db_redis_host
  })
}


# Next.js GCE 인스턴스
resource "google_compute_instance" "fe" {
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

  metadata_startup_script = local.startup_script_fe

  service_account {
    scopes = ["cloud-platform"] # 전체 권한 부여 기능, 수정 필요 
  }

  labels = local.labels_fe
}


# Spring Boot GCE 인스턴스
resource "google_compute_instance" "be" {
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

  metadata_startup_script = local.startup_script_be

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = local.labels_be
}

# MySQL 및 Redis GCE 인스턴스 (하나의 인스턴스에서 실행)
resource "google_compute_instance" "db" {
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
    access_config {
      nat_ip = var.static_ip_db
    }
  }

  metadata_startup_script = local.startup_script_db

  service_account {
    scopes = ["cloud-platform"]
  }

  labels = local.labels_db
}

# Cloud DNS A 레코드 추가 (Next.js 인스턴스 외부 IP를 가리키도록)
resource "google_dns_record_set" "nextjs_dns_record" {
  project      = "leafresh"
  managed_zone = var.dns_zone_name
  name         = "${var.dns_record_name}."
  type         = "A"
  ttl          = 18000
  rrdatas      = [google_compute_instance.fe.network_interface[0].access_config[0].nat_ip]
}

# Cloud DNS A 레코드 추가 (Spring Boot BE 인스턴스 외부 IP를 가리키도록)
resource "google_dns_record_set" "springboot_dns_record" {
  project      = "leafresh"
  managed_zone = var.dns_zone_name
  name         = "be.${var.dns_record_name}." # 예: be.dev-leafresh.app..
  type         = "A"
  ttl          = 18000
  rrdatas      = [google_compute_instance.be.network_interface[0].access_config[0].nat_ip]
}

