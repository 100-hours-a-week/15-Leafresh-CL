resource "google_compute_network" "vpc" {
  project                 = var.project_id
  name                    = var.project_name
  auto_create_subnetworks = false
}

