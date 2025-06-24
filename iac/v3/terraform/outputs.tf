# outputs.tf
output "vpc_id" {
  description = "The ID of the created VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Map of Public Subnet IDs by AZ."
  value       = module.public_subnets.subnet_ids
}

output "private_eks_subnet_ids" {
  description = "Map of EKS Private Subnet IDs by AZ."
  value       = module.private_eks_subnets.subnet_ids
}

output "private_data_subnet_ids" {
  description = "Map of Data Tier Private Subnet IDs by AZ."
  value       = module.private_data_subnets.subnet_ids
}

output "private_app_workload_subnet_ids" {
  description = "Map of App Workload Private Subnet IDs by AZ."
  value       = module.private_app_workload_subnets.subnet_ids
}

output "private_ops_tools_subnet_ids" {
  description = "Map of Ops Tools Private Subnet IDs by AZ."
  value       = module.private_ops_tools_subnets.subnet_ids
}

output "private_monitoring_subnet_ids" {
  description = "Map of Monitoring Private Subnet IDs by AZ."
  value       = module.private_monitoring_subnets.subnet_ids
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.network_gateways.igw_id
}

output "nat_gateway_ids" {
  description = "A map of NAT Gateway IDs by AZ."
  value       = module.network_gateways.natgw_ids
}
