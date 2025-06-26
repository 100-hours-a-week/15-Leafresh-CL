# outputs.tf
output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnets_map" {
  description = "Map of subnet_key → Public Subnet ID"
  value       = module.subnets.public_subnets_map
}

output "private_subnets_map" {
  description = "Map of subnet_key → Private Subnet ID"
  value       = module.subnets.private_subnets_map
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.gateways.igw_id
}

output "nat_gateway_map" {
  description = "Map of subnet_key → NAT Gateway ID"
  value       = module.gateways.natgw_map
}