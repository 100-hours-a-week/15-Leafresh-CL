resource "google_storage_bucket" "images" {
  location      = var.region
  project       = var.project_id_dev
  name          = var.storage_name
  storage_class = var.storage_class
  force_destroy = var.storage_force_destroy

  uniform_bucket_level_access = true

  cors {
    origin          = var.storage_cors_origin
    method          = var.storage_cors_method
    response_header = var.storage_cors_response_header
    max_age_seconds = var.storage_cors_max_age_seconds
  }

  labels = {
    environment = "dev"
    purpose     = "images"
  }
}