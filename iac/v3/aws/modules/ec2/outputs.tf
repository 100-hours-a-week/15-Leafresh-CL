# # modules/ec2/outputs.tf
# # output "instance_ids" {
# #   description = "생성된 EC2 인스턴스 ID 리스트"
# #   value       = { for name, inst in aws_instance.nodes : name => inst.id }
# # }

# # output "public_ips" {
# #   description = "GPU 인스턴스 퍼블릭 IP (없으면 null)"
# #   value       = module.ec2_worker.public_ips
# # }

# # output "private_ips" {
# #   description = "모든 인스턴스 프라이빗 IP"
# #   # master + worker 전체 IP 맵을 하나로 합치기
# #   value       = merge(
# #     module.ec2_master.private_ips,
# #     module.ec2_worker.private_ips
# #   )
# # }

# # 1) ASG에서 첫 인스턴스 ID 뽑기
# locals {
#   instance_ids_map = {
#     for name, ag in aws_autoscaling_group.this :
#     name => ag.instances[0].instance_id
#   }
# }

# # 2) 각 ID별 EC2 정보 조회
# data "aws_instance" "asg_node" {
#   for_each    = local.instance_ids_map
#   # instance_id = each.value
#   filter {
#     name   = "tag:aws:autoscaling:groupName"
#     values = [each.value]
#   }
# }

# # 3) Outputs
# output "sg_k8s_id" {
#   description = "Kubernetes SG ID"
#   value       = aws_security_group.k8s.id
# }

# output "sg_gpu_id" {
#   description = "GPU SG ID"
#   value       = aws_security_group.gpu.id
# }

# output "launch_templates" {
#   description = "각 EC2 노드별 Launch Template ID map"
#   value       = { for name, lt in aws_launch_template.this : name => lt.id }
# }

# output "instance_ids" {
#   description = "Map of node name → first EC2 instance ID"
#   value       = local.instance_ids_map
# }

# output "asg_ids" {
#   description = "각 EC2 노드별 ASG ID map"
#   value       = { for name, ag in aws_autoscaling_group.this : name => ag.id }
# }

# output "asg_arns" {
#   description = "각 EC2 노드별 ASG ARN map"
#   value       = { for name, ag in aws_autoscaling_group.this : name => ag.arn }
# }

# output "public_ips" {
#   description = "Map of node → public IP"
#   value       = { for name, inst in data.aws_instance.asg_node : name => inst.public_ip }
# }

# output "private_ips" {
#   description = "Map of node → private IP"
#   value       = { for name, inst in data.aws_instance.asg_node : name => inst.private_ip }
# }


# modules/ec2/outputs.tf

# 1) ASG 리소스에서 실제 그룹 이름(Name) 맵으로 추출
locals {
  asg_name_map = {
    for key, ag in aws_autoscaling_group.this :
    key => ag.name
  }
}

# 2) 태그 "aws:autoscaling:groupName" 으로 ASG 인스턴스 필터링
data "aws_instances" "asg_nodes" {
  for_each = local.asg_name_map

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [each.value]
  }
}
# :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

# 3) 각 ASG 당 첫 번째 인스턴스 ID만 뽑아서 맵으로 정리
locals {
  instance_id_map = {
    for key, inst in data.aws_instances.asg_nodes :
    key => inst.ids[0]
  }
}

# 4) 해당 인스턴스 ID 로부터 public/private IP 조회
data "aws_instance" "first_node" {
  for_each    = local.instance_id_map
  instance_id = each.value
}

# 5) Outputs
output "launch_templates" {
  description = "각 노드별 Launch Template ID map"
  value       = { for name, lt in aws_launch_template.this : name => lt.id }
}

output "asg_ids" {
  description = "각 노드별 ASG ID map"
  value       = { for name, ag in aws_autoscaling_group.this : name => ag.id }
}

output "asg_arns" {
  description = "각 노드별 ASG ARN map"
  value       = { for name, ag in aws_autoscaling_group.this : name => ag.arn }
}

output "instance_ids" {
  description = "각 노드별 EC2 인스턴스 ID map"
  value       = local.instance_id_map
}

output "public_ips" {
  description = "각 노드별 Public IP map"
  value       = { for name, inst in data.aws_instance.first_node : name => inst.public_ip }
}

output "private_ips" {
  description = "각 노드별 Private IP map"
  value       = { for name, inst in data.aws_instance.first_node : name => inst.private_ip }
}
