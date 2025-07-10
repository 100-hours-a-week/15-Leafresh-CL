output "vpc_name" {
  description = "생성된 VPC의 이름"
  value       = google_compute_network.vpc.name
}

output "vpc_self_link" {
  description = "Self link of the created VPC"
  value       = google_compute_network.vpc.self_link
}

