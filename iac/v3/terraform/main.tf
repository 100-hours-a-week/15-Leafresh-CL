# main.tf (Root Module)
locals {
  nat_gateway_ids_map = {
    for az in var.availability_zones : az => module.network_gateways.natgw_ids[az]
  }
}

module "vpc" {
  source = "./modules/vpc"
  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block
}

module "network_gateways" {
  source = "./modules/gateway"
  vpc_id            = module.vpc.vpc_id
  vpc_name          = var.vpc_name
  public_subnet_ids = module.public_subnets.subnet_ids
}

# Public Subnets
module "public_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs # Pass the /19 base for each AZ
  offset                  = var.subnet_offsets.public # Pass the offset within the /19
  prefix_length           = var.subnet_prefixes.public
  name_prefix             = "Public"
  tier_tag                = "Public"
  map_public_ip_on_launch = true
  is_public               = true
  internet_gateway_id     = module.network_gateways.igw_id
  needs_route_table       = true
}

# Private EKS Subnets
module "private_eks_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs
  offset                  = var.subnet_offsets.eks
  prefix_length           = var.subnet_prefixes.eks
  name_prefix             = "Private-EKS"
  tier_tag                = "Private-EKS"
  nat_gateway_ids         = local.nat_gateway_ids_map
  additional_tags = {
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}

# Private Data Subnets
module "private_data_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs
  offset                  = var.subnet_offsets.data
  prefix_length           = var.subnet_prefixes.data
  name_prefix             = "Private-DataTier"
  tier_tag                = "Private-Data"
  nat_gateway_ids         = local.nat_gateway_ids_map
}

# Private App Workload Subnets
module "private_app_workload_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs
  offset                  = var.subnet_offsets.app
  prefix_length           = var.subnet_prefixes.app
  name_prefix             = "Private-AppWorkload"
  tier_tag                = "Private-App"
  nat_gateway_ids         = local.nat_gateway_ids_map
}

# Private Ops Tools Subnets
module "private_ops_tools_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs
  offset                  = var.subnet_offsets.ops
  prefix_length           = var.subnet_prefixes.ops
  name_prefix             = "Private-OpsTools"
  tier_tag                = "Private-Ops"
  nat_gateway_ids         = local.nat_gateway_ids_map
}

# Private Monitoring Subnets
module "private_monitoring_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs
  offset                  = var.subnet_offsets.monitoring
  prefix_length           = var.subnet_prefixes.monitoring
  name_prefix             = "Private-Monitoring"
  tier_tag                = "Private-Monitoring"
  nat_gateway_ids         = local.nat_gateway_ids_map
}

# Private Reserved Subnets
module "private_reserved_subnets" {
  source = "./modules/subnets"

  vpc_id                  = module.vpc.vpc_id
  availability_zones      = var.availability_zones
  base_az_cidr_block      = var.az_base_cidrs
  offset                  = var.subnet_offsets.reserved
  prefix_length           = var.subnet_prefixes.reserved
  name_prefix             = "Private-Reserved"
  tier_tag                = "Private-Reserved"
  nat_gateway_ids         = local.nat_gateway_ids_map
}

# Security Groups
module "security_groups" {
  source = "./modules/security_groups"

  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block    = var.vpc_cidr_block # VPC CIDR 블록 전달
  name_prefix       = var.vpc_name # 보안 그룹 이름에 VPC 이름을 접두사로 사용
  allowed_ssh_cidrs = var.allowed_ssh_cidrs # SSH 허용 CIDR 전달
}
