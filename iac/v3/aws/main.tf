# helm modules
# =====================================================================
data "aws_lb" "nginx_ingress" {
  name = "${var.project_name}-${module.nginx_ingress.release_name}"
  depends_on = [
    module.nginx_ingress
  ]
}

module "nginx_ingress" {
  source = "./modules/nginx_ingress"

  # (필요시 값 오버라이드)
  name                    = "nginx-ingress"
  namespace               = "ingress-nginx"
  service_type            = "LoadBalancer"
  load_balancer_type      = "nlb"
  publish_service_enabled = true
}


# AWS modules
# =====================================================================
module "vpc" {
  source     = "./modules/vpc"
  name       = "${var.project_name}-vpc"
  cidr_block = var.vpc_cidr_block
}


module "subnets" {
  source               = "./modules/subnet"
  project_name         = var.project_name
  region               = var.region
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}


module "s3" {
  source        = "./modules/s3"
  project_name  = var.project_name
  bucket_suffix = var.s3_bucket_suffixes
}


module "sqs" {
  source            = "./modules/sqs"
  project_name      = var.project_name
  queue_names       = var.sqs_fifo_queue_names
  dlq_queue_names   = var.sqs_fifo_dlq_queue_names
  max_receive_count = var.sqs_fifo_max_receive_count
}


module "rds" {
  source         = "./modules/rds"
  project_name   = var.project_name
  instance_class = var.rds_instance_class
  engine         = var.rds_engine
  engine_version = var.rds_engine_version
  multi_az       = var.rds_multi_az
  db_username    = var.rds_username
  db_password    = var.rds_password
  storage_type   = var.rds_storage_type
  subnet_ids = [
    module.subnets.private_subnet_ids_map["a-2"],
    module.subnets.private_subnet_ids_map["c-2"]
  ]
}


module "ec2_master" {
  source                 = "./modules/ec2"
  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  region                 = var.region
  ec2_nodes              = local.ec2_master_node
  attach_iam = true
  access_key_id          = var.ec2_access_key_id
  secret_access_key      = var.ec2_secret_access_key
}

module "ec2_worker" {
  source                 = "./modules/ec2"
  project_name           = var.project_name
  vpc_id                 = module.vpc.vpc_id
  region                 = var.region
  ec2_nodes              = local.ec2_worker_nodes
  attach_iam = false
  iam_profile_name  = module.ec2_master.iam_profile_name
  access_key_id          = var.ec2_access_key_id
  secret_access_key      = var.ec2_secret_access_key
  depends_on             = [module.ec2_master]
}


module "ecr" {
  source           = "./modules/ecr"
  project_name     = var.project_name
  repository_names = var.ecr_repository_names
}


module "vpn" {
  source                      = "./modules/vpn"
  subnet_ids                  = local.subnet_map
  project_name                = var.project_name
  vpc_cidr_block              = var.vpc_cidr_block
  # server_certificate_arn      = module.acm_vpn_server_req.certificate_arn
  # client_root_certificate_arn = module.acm_vpn_client_req.certificate_arn
  client_cidr_block           = var.vpn_client_cidr_block
  # depends_on = [
  #   module.acm_server_val.validation_complete,
  #   module.acm_client_val.validation_complete
  # ]
}


module "cloudfront" {
  source             = "./modules/cloudfront"
  origin_domain_name = data.aws_lb.nginx_ingress.dns_name
  aliases            = [var.gcp_dns_domain_name]
  certificate_arn    = module.acm_ingress_req.certificate_arn
  web_acl_id         = module.waf.web_acl_arn
}


module "waf" {
  source       = "./modules/waf"
  project_name = var.project_name
  resource_arn = data.aws_lb.nginx_ingress.arn
}


# module "acm_vpn_server_req" {
#   source                    = "./modules/acm/request"
#   project_name              = var.project_name
#   domain_name               = var.vpn_server_domain
#   subject_alternative_names = []
#   tag                       = "vpn-server"
# }

# module "acm_vpn_client_req" {
#   source                    = "./modules/acm/request"
#   project_name              = var.project_name
#   domain_name               = var.vpn_client_domain
#   subject_alternative_names = []
#   tag                       = "vpn-client"
# }

module "acm_ingress_req" {
  source                    = "./modules/acm/request"
  project_name              = var.project_name
  domain_name               = var.gcp_dns_domain_name
  subject_alternative_names = []
  tag                       = "alb-ingress"
}


module "gcp_dns_vpn_server" {
  source                    = "./modules/dns"
  project_id                = var.gcp_project_id
  zone_name                 = var.gcp_dns_zone_name
  domain_validation_options = module.vpn.server_domain_validation_options
}

module "gcp_dns_vpn_client" {
  source                    = "./modules/dns"
  project_id                = var.gcp_project_id
  zone_name                 = var.gcp_dns_zone_name
  domain_validation_options = module.vpn.client_domain_validation_options
}

module "gcp_dns_ingress" {
  source                    = "./modules/dns"
  project_id                = var.gcp_project_id
  zone_name                 = var.gcp_dns_zone_name
  domain_validation_options = module.acm_ingress_req.domain_validation_options
}


module "acm_server_val" {
  source                  = "./modules/acm/validate"
  certificate_arn         = module.vpn.server_certificate_arn
  validation_record_fqdns = module.gcp_dns_vpn_server.fqdns
}

module "acm_client_val" {
  source                  = "./modules/acm/validate"
  certificate_arn         = module.vpn.client_certificate_arn
  validation_record_fqdns = module.gcp_dns_vpn_client.fqdns
}

module "acm_ingress_val" {
  source                  = "./modules/acm/validate"
  certificate_arn         = module.acm_ingress_req.certificate_arn
  validation_record_fqdns = module.gcp_dns_ingress.fqdns
}
