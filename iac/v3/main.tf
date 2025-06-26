# main.tf

module "vpc" {
  source     = "./modules/vpc"
  name       = "${var.project_name}-vpc"
  cidr_block = var.vpc_cidr_block
}

