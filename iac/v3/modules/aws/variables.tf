# variables.tf

# k8s variables
# =====================================================================
variable "kubeconfig_path" {
  description = "Config file of k8s"
  type        = string
  default     = "/home/ubuntu/.kube/config"
}

variable "k8s_service_namespace" {
  description = "Name of Service Namespace of k8s"
  type        = string
  default     = "service"
}



# =====================================================================================================


# default variables
# =====================================================================
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "leafresh"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast3"
}

variable "gcp_project_id" {
  description = "Project Name of GCP that includes Cloud DNS"
  type        = string
  default     = "leafresh"
}



# tag variables
# =====================================================================
variable "tag_environment" {
  description = "Runnung Environment as tag"
  type        = string
  default     = "Dev"
}



# VPC variables
# =====================================================================
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/18)."
  type        = string
  default     = "10.0.0.0/16"
}



# subnet variables
# =====================================================================
variable "public_subnet_cidrs" {
  description = "Map of AZ suffixes to public subnet CIDRs"
  type        = map(string)
  default = {
    a = "10.0.1.0/24"
    c = "10.0.101.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "Map of AZ-suffix-index to private subnet CIDRs (e.g. a-1)"
  type        = map(string)
  default = {
    "a-1" = "10.0.2.0/24"
    "a-2" = "10.0.3.0/24"
    "c-1" = "10.0.102.0/24"
    "c-2" = "10.0.103.0/24"
  }
}



# S3 variables
# =====================================================================
variable "s3_bucket_suffixes" {
  description = "List of suffixes for S3 buckets"
  type        = list(string)
  default     = ["images", "prod-images", "logs"]
}



# RDS variables
# =====================================================================
variable "rds_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "root"
}

variable "rds_password" {
  description = "Master password for the RDS instance"
  type        = string
  default     = "Rlatldms!2!3"
  sensitive   = true
}

variable "rds_instance_class" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.m5.xlarge"
}

variable "rds_engine" {
  description = "Instance engine for the RDS instance"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "Instance engine version for the RDS instance"
  type        = string
  default     = "8.0"
}

variable "rds_storage_type" {
  description = "Storage type for the RDS instance"
  type        = string
  default     = "gp3"
}

variable "rds_multi_az" {
  description = "Multi AZ setting for the RDS instance"
  type        = bool
  default     = false
}



# SQS variables
# =====================================================================
variable "sqs_fifo_queue_names" {
  description = "List of FIFO SQS queue suffixes"
  type        = list(string)
  default     = ["order", "images", "feedback", "feedback-result", ""]
}

variable "sqs_fifo_dlq_queue_names" {
  description = "List of FIFO SQS queues that require DLQ"
  type        = list(string)
  default     = ["order"]
}

variable "sqs_fifo_max_receive_count" {
  description = "MaxReceiveCount for DLQ redrive policy"
  type        = number
  default     = 5
}



# EC2 variables & locals
# =====================================================================
locals {
  ec2_master_node = [
    {
      name          = "monitoring"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.small"
      subnet_id     = module.subnets.private_subnet_ids_map["c-1"]
      role          = "k8s"
    },
  ]
  
  ec2_worker_nodes = [
    {
      name          = "master"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.small"
      subnet_id     = module.subnets.private_subnet_ids_map["a-1"]
      role          = "k8s"
    },
    {
      name          = "fe"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.medium"
      subnet_id     = module.subnets.private_subnet_ids_map["a-1"]
      role          = "k8s"
    },
    {
      name          = "be"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.medium"
      subnet_id     = module.subnets.private_subnet_ids_map["a-1"]
      role          = "k8s"
    },
    {
      name          = "argocd"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.small"
      subnet_id     = module.subnets.private_subnet_ids_map["a-1"]
      role          = "k8s"
    },
    {
      name          = "ai-cpu"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.xlarge"
      subnet_id     = module.subnets.private_subnet_ids_map["a-1"]
      role          = "gpu"
    },
    {
      name          = "ai-gpu"
      ami           = "ami-060449aa9aa36d665"
      instance_type = "t3.xlarge" # "g4dn.xlarge"
      subnet_id     = module.subnets.private_subnet_ids_map["a-1"]
      role          = "gpu"
    },
    {
      name          = "redis-master"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.small"
      subnet_id     = module.subnets.private_subnet_ids_map["a-2"]
      role          = "k8s"
    },
    {
      name          = "redis-slave"
      ami           = "ami-0662f4965dfc70aca"
      instance_type = "t3.small"
      subnet_id     = module.subnets.private_subnet_ids_map["c-2"]
      role          = "k8s"
    },
  ]

  asg_k8s = {
    subnet_ids = [
      module.subnets.private_subnet_ids_map["a-1"],
      module.subnets.private_subnet_ids_map["c-1"],
    ]
    min_size         = 1
    max_size         = 2
    desired_capacity = 1
  }
}



# ECR variables
# =====================================================================
variable "ecr_repository_names" {
  description = "Lists of ECR repository to create."
  type        = list(string)
  default     = ["ecr"]
}



# DNS variables
# =====================================================================
variable "gcp_dns_zone_name" {
  description = "Managed Zone of GCP DNS"
  type        = string
  default     = "dev-leafresh.app."
}

variable "gcp_dns_domain_name" {
  description = "Domain name of GCP DNS"
  type        = string
  default     = "dev-leafresh.app"
}


# ACM variables
# =====================================================================
variable "vpn_server_domain" {
  description = "Server Domain of VPN"
  type        = string
  default     = "vpn.dev-leafresh.app"
}

variable "vpn_client_domain" {
  description = "Client Domain of VPN"
  type        = string
  default     = "client.dev-leafresh.app"
}


# VPN variables
# =====================================================================
locals {
  all_subnet_ids = concat(
    module.subnets.public_subnet_ids,
    module.subnets.private_subnet_ids
  )

  subnet_map = zipmap(
    [for idx, val in local.all_subnet_ids : "subnet-${idx}"],
    local.all_subnet_ids
  )
}

variable "vpn_client_cidr_block" {
  description = "CIDR block assigned to VPN"
  type        = string
  default     = "10.0.30.0/24"
}



# LB Controller variables
# =====================================================================
variable "cluster_oidc_url" {
  description = "CIDR block assigned to VPN"
  type        = string
  default     = ""
}

variable "cluster_oidc_thumbprint" {
  description = "CIDR block assigned to VPN"
  type        = string
  default     = ""
}
