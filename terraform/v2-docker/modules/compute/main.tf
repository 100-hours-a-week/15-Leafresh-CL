# Next.js 인스턴스 (Public Subnet)
resource "google_compute_instance" "nextjs" {
  name         = var.nextjs_instance_name
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-medium" # 필요에 따라 머신 유형 변경
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # 필요에 따라 이미지 변경
    }
  }
  network_interface {
    subnetwork = var.public_subnet_id
    access_config {} # 공용 IP 할당
  }
  tags = merge(var.tags, {"tier" : "frontend", "app" : "nextjs"})
}

# SpringBoot 인스턴스 (Private Subnet)
resource "google_compute_instance" "springboot" {
  name         = var.springboot_instance_name
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-medium" # 필요에 따라 머신 유형 변경
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11" # 필요에 따라 이미지 변경
    }
  }
  network_interface {
    subnetwork = var.private_app_subnet_id
  }
  tags = merge(var.tags, {"tier" : "backend", "app" : "springboot"})
}
