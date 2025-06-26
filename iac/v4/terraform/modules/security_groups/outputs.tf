# modules/security_groups/outputs.tf
output "ssh_sg_id" {
  description = "The ID of the Security Group allowing SSH access."
  value       = aws_security_group.ssh.id
}

output "eks_cluster_sg_id" {
  description = "The ID of the Security Group for EKS cluster control plane."
  value       = aws_security_group.eks_cluster.id
}

output "eks_worker_sg_id" {
  description = "The ID of the Security Group for EKS worker nodes."
  value       = aws_security_group.eks_worker.id
}

output "db_sg_id" {
  description = "The ID of the Security Group allowing database access."
  value       = aws_security_group.db.id
}

output "ai_sg_id" {
  description = "The ID of the Security Group for application servers."
  value       = aws_security_group.ai.id
}

output "ops_sg_id" {
  description = "The ID of the Security Group for operations tools."
  value       = aws_security_group.ops.id
}

output "monitoring_sg_id" {
  description = "The ID of the Security Group for monitoring services."
  value       = aws_security_group.monitoring.id
}
