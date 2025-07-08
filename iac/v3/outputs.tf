// outputs.tf (root)

///////////////////////////////////////////////////////////////////////////////
// VPC 모듈
///////////////////////////////////////////////////////////////////////////////
output "vpc_id" {
  description = "Leafresh VPC ID"
  value       = module.vpc.vpc_id
}

output "internet_gateway_id" {
  description = "Leafresh Internet Gateway ID"
  value       = module.vpc.igw_id
}

///////////////////////////////////////////////////////////////////////////////
// Subnet 모듈
///////////////////////////////////////////////////////////////////////////////
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.subnets.private_subnet_ids
}

///////////////////////////////////////////////////////////////////////////////
// S3 모듈
///////////////////////////////////////////////////////////////////////////////
output "s3_bucket_names" {
  description = "Names of all S3 buckets"
  value       = module.s3.bucket_ids
}

///////////////////////////////////////////////////////////////////////////////
// RDS 모듈
///////////////////////////////////////////////////////////////////////////////
output "rds_instance_id" {
  description = "RDS instance ID"
  value       = module.rds.instance_id
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = module.rds.instance_endpoint
}

///////////////////////////////////////////////////////////////////////////////
// SQS 모듈
///////////////////////////////////////////////////////////////////////////////
// Queue
output "sqs_queue_urls" {
  description = "URL of the leafresh-sqs-order FIFO queue"
  value       = module.sqs.queue_urls
}

// DLQ
output "sqs_dlq_urls" {
  description = "URL of the leafresh-sqs-images FIFO queue"
  value       = module.sqs.dlq_urls
}

///////////////////////////////////////////////////////////////////////////////
// ECR 모듈
///////////////////////////////////////////////////////////////////////////////
output "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  value       = module.ecr.repository_urls
}

///////////////////////////////////////////////////////////////////////////////
// EC2 모듈
///////////////////////////////////////////////////////////////////////////////
// 모든 노드별 Launch Template ID 맵 (key = ec2_nodes[].name)
output "ec2_launch_templates" {
  description = "Map of EC2 Launch Template IDs"
  value       = module.ec2.launch_templates
}

// EC2 인스턴스 정보
output "ec2_instance_ids" {
  description = "List of EC2 instance IDs"
  value       = module.ec2.instance_ids
}

output "ec2_public_ips" {
  description = "List of EC2 public IP addresses (GPU 등)"
  value       = module.ec2.public_ips
}

output "ec2_private_ips" {
  description = "List of EC2 private IP addresses"
  value       = module.ec2.private_ips
}

# ///////////////////////////////////////////////////////////////////////////////
# // ALB 모듈
# ///////////////////////////////////////////////////////////////////////////////
# output "alb_arn" {
#   description = "Application Load Balancer ARN"
#   value       = module.alb.arn
# }

# output "alb_dns_name" {
#   description = "Application Load Balancer DNS name"
#   value       = module.alb.dns_name
# }

# output "alb_target_group_arn_fe" {
#   description = "ALB Target Group ARN"
#   value       = module.alb.target_group_arn_fe
# }

# ///////////////////////////////////////////////////////////////////////////////
# // NLB 모듈
# ///////////////////////////////////////////////////////////////////////////////
# output "nlb_arn" {
#   description = "Application Load Balancer ARN"
#   value       = module.nlb.arn
# }

# output "nlb_dns_name" {
#   description = "Application Load Balancer DNS name"
#   value       = module.nlb.dns_name
# }

///////////////////////////////////////////////////////////////////////////////
// ASG 모듈 (k8s-worker 전용)
///////////////////////////////////////////////////////////////////////////////
output "asg_names" {
  description = "Auto Scaling Group Name for k8s-worker"
  value       = module.asg.asg_names
}

output "asg_arns" {
  description = "Auto Scaling Group ARN for k8s-worker"
  value       = module.asg.asg_arns
}

///////////////////////////////////////////////////////////////////////////////
// VPN 모듈
///////////////////////////////////////////////////////////////////////////////
output "vpn_endpoint_id" {
  description = "Endpoint ID of Client VPN"
  value       = module.vpn.endpoint_id
}
output "vpn_endpoint_dns" {
  description = "Endpoint DNS of Client VPN"
  value       = module.vpn.endpoint_dns_name
}