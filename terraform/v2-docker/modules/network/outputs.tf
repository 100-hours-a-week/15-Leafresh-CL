# modules/network/outputs.tf

output "vpc_name" {
  description = "생성된 VPC의 이름"
  value       = google_compute_network.vpc.name
}

output "nextjs_subnet_self_link" {
  description = "Next.js Public Subnet의 Self Link"
  value       = google_compute_subnetwork.nextjs_public_subnet.self_link
}

output "springboot_subnet_self_link" {
  description = "Spring Boot Private Subnet의 Self Link"
  value       = google_compute_subnetwork.springboot_private_subnet.self_link
}

output "db_subnet_self_link" {
  description = "MySQL/Redis Private Subnet의 Self Link"
  value       = google_compute_subnetwork.db_private_subnet.self_link
}
