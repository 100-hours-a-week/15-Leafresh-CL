# modules/memorystore/main.tf

resource "google_redis_instance" "default" {
  name               = var.instance_name
  project            = var.project_id
  region             = var.region
  tier               = var.tier
  memory_size_gb     = var.memory_size_gb
  authorized_network = var.network
}

