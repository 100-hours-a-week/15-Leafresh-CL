# modules/sql/main.tf

locals {
  merged_labels_database = merge({}, {
    purpose = "sql-database"
    role    = "sql"
  })
}

resource "google_sql_database_instance" "default" {
  name             = var.db_instance_name
  project          = var.project_id
  region           = var.region
  database_version = var.database_version

  settings {
    tier            = var.db_tier
    disk_size       = var.allocated_storage
    disk_autoresize = true

    ip_configuration {
      ipv4_enabled = true

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }

      private_network = var.network
    }

    user_labels = local.merged_labels_database
  }
}

resource "google_sql_database" "default" {
  name     = var.database_name
  instance = google_sql_database_instance.default.name
  project  = var.project_id
}

resource "google_sql_user" "root" {
  name        = "root"
  instance    = google_sql_database_instance.default.name
  project     = var.project_id
  host        = "%"
  password_wo = var.root_password
}

