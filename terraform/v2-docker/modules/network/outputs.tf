output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "public_subnet_id" {
  value = google_compute_subnetwork.public.id
}

output "private_app_subnet_id" {
  value = google_compute_subnetwork.private_app.id
}

output "private_db_subnet_id" {
  value = google_compute_subnetwork.private_db.id
}
