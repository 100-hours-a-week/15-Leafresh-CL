# modules/network/outputs.tf

output "subnet_fe_self_link" {
  description = "Next.js Public Subnet의 Self Link"
  value       = google_compute_subnetwork.public_subnet_fe.self_link
}

output "subnet_be_self_link" {
  description = "Spring Boot Private Subnet의 Self Link"
  value       = google_compute_subnetwork.private_subnet_be.self_link
}

output "subnet_db_self_link" {
  description = "MySQL/Redis Private Subnet의 Self Link"
  value       = google_compute_subnetwork.private_subnet_db.self_link
}

# output "nat_gateway_ip" {
#   description = "NAT Gateway의 외부 IP 주소"
#   value       = google_compute_address.nat_ip.address
# }

output "static_ip_fe" {
  description = "FE의 외부 IP 주소"
  value       = google_compute_address.static_ip_fe.address
}

output "static_ip_be" {
  description = "BE의 외부 IP 주소"
  value       = google_compute_address.static_ip_be.address
}

output "static_ip_db" {
  description = "DB의 외부 IP 주소"
  value       = google_compute_address.static_ip_db.address
}