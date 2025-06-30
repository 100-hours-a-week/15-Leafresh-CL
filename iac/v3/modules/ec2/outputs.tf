# modules/ec2/outputs.tf
output "instance_ids" {
  description = "생성된 EC2 인스턴스 ID 리스트"
  value       = [for _, inst in aws_instance.nodes : inst.id]
}

output "public_ips" {
  description = "GPU 인스턴스 퍼블릭 IP (없으면 null)"
  value       = [for _, inst in aws_instance.nodes : inst.public_ip]
}

output "private_ips" {
  description = "모든 인스턴스 프라이빗 IP"
  value       = [for _, inst in aws_instance.nodes : inst.private_ip]
}

output "sg_k8s_id" {
  description = "Kubernetes SG ID"
  value       = aws_security_group.k8s.id
}

output "sg_gpu_id" {
  description = "GPU SG ID"
  value       = aws_security_group.gpu.id
}

output "launch_templates" {
  description = "각 EC2 노드별 Launch Template ID map"
  value       = { for name, lt in aws_launch_template.template : name => lt.id }
}
