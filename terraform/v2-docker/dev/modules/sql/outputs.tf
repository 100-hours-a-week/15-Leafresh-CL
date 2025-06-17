# modules/sql/outputs.tf

output "private_ip_address" {
  description = "Cloud SQL Private IP 주소"
  value       = google_sql_database_instance.default.ip_address[0].ip_address
}

