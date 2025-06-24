# modules/security_groups/outputs.tf
output "ssh_access_sg_id" {
  description = "The ID of the Security Group allowing SSH access."
  value       = aws_security_group.ssh_access.id
}

output "eks_cluster_sg_id" {
  description = "The ID of the Security Group for EKS cluster control plane."
  value       = aws_security_group.eks_cluster.id
}

output "eks_worker_node_sg_id" {
  description = "The ID of the Security Group for EKS worker nodes."
  value       = aws_security_group.eks_worker_node.id
}

output "database_access_sg_id" {
  description = "The ID of the Security Group allowing database access."
  value       = aws_security_group.database_access.id
}

output "app_server_sg_id" {
  description = "The ID of the Security Group for application servers."
  value       = aws_security_group.app_server.id
}

output "ops_tools_sg_id" {
  description = "The ID of the Security Group for operations tools."
  value       = aws_security_group.ops_tools.id
}

output "monitoring_sg_id" {
  description = "The ID of the Security Group for monitoring services."
  value       = aws_security_group.monitoring.id
}
