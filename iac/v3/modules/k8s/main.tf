# main.tf


# k8s modules
# =====================================================================
module "ns_frontend" {
  source    = "./modules/k8s/namespace"
  namespace = "frontend"
}
module "fe" {
  source    = "./modules/k8s/deployment"
  name      = "fe"
  namespace = module.ns_frontend.namespace
  image     = "${module.ecr.repository_urls["ecr"]}/frontend-develop:latest"
  port      = 5173
  replicas  = 1
}

module "fe_svc" {
  source      = "./modules/k8s/service"
  name        = "fe-service"
  namespace   = module.ns_frontend.namespace
  port        = 80
  target_port = 5173
  type        = "ClusterIP"
}
module "fe_ingress" {
  source              = "./modules/k8s/ingress"
  name                = "${var.project_name}-k8s-ingress"
  namespace           = module.ns_frontend.namespace
  domain_name         = var.gcp_dns_domain_name
  service_name        = module.fe_svc.name
  service_port        = module.fe_svc.port
  kubeconfig_path     = var.kubeconfig_path
  alb_certificate_arn = module.acm_alb_req.certificate_arn
}


module "ns_backend" {
  source    = "./modules/k8s/namespace"
  namespace = "backend"
}
module "be" {
  source    = "./modules/k8s/deployment"
  name      = "be"
  namespace = module.ns_backend.namespace
  image     = "${module.ecr.repository_urls["ecr"]}/backend-develop:latest"
  port      = 3000
  replicas  = 1
}
module "be_svc" {
  source      = "./modules/k8s/service"
  name        = "be-service"
  namespace   = module.ns_backend.namespace
  port        = 80
  target_port = 3000
  type        = "LoadBalancer"
}


module "ns_ai" {
  source    = "./modules/k8s/namespace"
  namespace = "ai"
}

module "ai" {
  source    = "./modules/k8s/deployment"
  name      = "ai"
  namespace = module.ns_ai.namespace
  image     = "${module.ecr.repository_urls["ecr"]}/ai-develop:latest"
  port      = 8000
  replicas  = 1
}

module "ai_svc" {
  source      = "./modules/k8s/service"
  name        = "ai-service"
  namespace   = module.ns_ai.namespace
  port        = 8000
  target_port = 8000
  type        = "LoadBalancer"
}


module "ns_redis" {
  source    = "./modules/k8s/namespace"
  namespace = "redis"
}

module "redis_cfg" {
  source    = "./modules/k8s/configmap"
  name      = "redis-config"
  namespace = module.ns_redis.namespace
  data = {
    "redis.conf" = file("${path.module}/modules/k8s/templates/redis.conf")
  }
}

module "redis_master" {
  source          = "./modules/k8s/statefulset"
  name            = "redis-master"
  namespace       = module.ns_redis.namespace
  service_name    = "redis-master"
  replicas        = 1
  container_image = "redis:7.4"
  container_port  = 6379
  config_map_name = module.redis_cfg.name
}

module "redis_slave" {
  source          = "./modules/k8s/statefulset"
  name            = "redis-slave"
  namespace       = module.ns_redis.namespace
  service_name    = "redis-slave"
  replicas        = 1
  container_image = "redis:7.4"
  container_port  = 6379
  config_map_name = module.redis_cfg.name
}

module "redis_master_svc" {
  source      = "./modules/k8s/service"
  name        = "redis-master"
  namespace   = module.ns_redis.namespace
  port        = 6379
  target_port = 6379
  type        = "ClusterIP"
}

module "redis_slave_svc" {
  source      = "./modules/k8s/service"
  name        = "redis-slave"
  namespace   = module.ns_redis.namespace
  port        = 6379
  target_port = 6379
  type        = "ClusterIP"
}


module "ns_monitoring" {
  source    = "./modules/k8s/namespace"
  namespace = "monitoring"
}

module "prometheus" {
  source    = "./modules/k8s/deployment"
  name      = "prometheus"
  namespace = module.ns_monitoring.namespace
  image     = "prom/prometheus:latest"
  port      = 9090
  replicas  = 1
  node_selector = {
    "node-role.kubernetes.io/monitoring" = "true"
  }
}

module "prometheus_svc" {
  source      = "./modules/k8s/service"
  name        = "prometheus"
  namespace   = module.ns_monitoring.namespace
  port        = 9090
  target_port = 9090
  type        = "ClusterIP"
}

module "loki" {
  source    = "./modules/k8s/deployment"
  name      = "loki"
  namespace = module.ns_monitoring.namespace
  image     = "grafana/loki:latest"
  port      = 3100
  replicas  = 1
  node_selector = {
    "node-role.kubernetes.io/monitoring" = "true"
  }
}

module "loki_svc" {
  source      = "./modules/k8s/service"
  name        = "loki"
  namespace   = module.ns_monitoring.namespace
  port        = 3100
  target_port = 3100
  type        = "ClusterIP"
}

module "grafana" {
  source    = "./modules/k8s/deployment"
  name      = "grafana"
  namespace = module.ns_monitoring.namespace
  image     = "grafana/grafana:latest"
  port      = 3000
  replicas  = 1
  node_selector = {
    "node-role.kubernetes.io/monitoring" = "true"
  }
}

module "grafana_svc" {
  source      = "./modules/k8s/service"
  name        = "grafana"
  namespace   = module.ns_monitoring.namespace
  port        = 3000
  target_port = 3000
  type        = "LoadBalancer"
}

module "jaeger" {
  source    = "./modules/k8s/deployment"
  name      = "jaeger"
  namespace = module.ns_monitoring.namespace
  image     = "jaegertracing/all-in-one:latest"
  port      = 16686
  replicas  = 1
  node_selector = {
    "node-role.kubernetes.io/monitoring" = "true"
  }
}

module "jaeger_svc" {
  source      = "./modules/k8s/service"
  name        = "jaeger"
  namespace   = module.ns_monitoring.namespace
  port        = 16686
  target_port = 16686
  type        = "ClusterIP"
}

module "monitor_ingress" {
  source              = "./modules/k8s/ingress"
  name                = "monitoring-ingress"
  namespace           = module.ns_monitoring.namespace
  domain_name         = "monitor.leafresh.app"
  service_name        = module.grafana_svc.name
  service_port        = module.grafana_svc.port
  alb_certificate_arn = module.acm_alb_req.certificate_arn
  kubeconfig_path     = var.kubeconfig_path
}



# # AWS modules
# # =====================================================================
# module "vpc" {
#   source     = "./modules/aws/vpc"
#   name       = "${var.project_name}-vpc"
#   cidr_block = var.vpc_cidr_block
# }


# module "subnets" {
#   source               = "./modules/aws/subnet"
#   project_name         = var.project_name
#   region               = var.region
#   vpc_id               = module.vpc.vpc_id
#   igw_id               = module.vpc.igw_id
#   public_subnet_cidrs  = var.public_subnet_cidrs
#   private_subnet_cidrs = var.private_subnet_cidrs
# }


# module "s3" {
#   source        = "./modules/aws/s3"
#   project_name  = var.project_name
#   bucket_suffix = var.s3_bucket_suffixes
# }


# module "sqs" {
#   source            = "./modules/aws/sqs"
#   project_name      = var.project_name
#   queue_names       = var.sqs_fifo_queue_names
#   dlq_queue_names   = var.sqs_fifo_dlq_queue_names
#   max_receive_count = var.sqs_fifo_max_receive_count
# }


# module "rds" {
#   source         = "./modules/aws/rds"
#   project_name   = var.project_name
#   instance_class = var.rds_instance_class
#   engine         = var.rds_engine
#   engine_version = var.rds_engine_version
#   multi_az       = var.rds_multi_az
#   db_username    = var.rds_username
#   db_password    = var.rds_password
#   storage_type   = var.rds_storage_type
#   subnet_ids = [
#     module.subnets.private_subnet_ids_map["a-2"],
#     module.subnets.private_subnet_ids_map["c-2"]
#   ]
# }


# module "ec2" {
#   source       = "./modules/aws/ec2"
#   project_name = var.project_name
#   vpc_id       = module.vpc.vpc_id # VPC 모듈 outputs 중 ID
#   region       = var.region
#   ec2_nodes    = local.ec2_nodes
# }


# # module "alb" {
# #   source                    = "./modules/aws/alb"
# #   project_name              = var.project_name
# #   vpc_id                    = module.vpc.vpc_id
# #   public_subnet_ids         = module.subnets.public_subnet_ids
# #   security_group_ids        = [module.ec2.sg_k8s_id]
# #   instance_id_k8s_worker_fe = module.ec2.instance_ids["k8s-worker-fe"]
# #   instance_id_k8s_worker_be = module.ec2.instance_ids["k8s-worker-be"]
# #   instance_id_monitoring    = module.ec2.instance_ids["monitoring"]
# #   instance_id_argocd        = module.ec2.instance_ids["argocd"]
# # }


# # module "nlb" {
# #   source       = "./modules/aws/nlb"
# #   project_name = var.project_name
# #   vpc_id       = module.vpc.vpc_id
# #   subnet_ids   = module.subnets.public_subnet_ids
# #   instance_ids = [module.ec2.instance_ids["k8s-worker-be"]]
# # }


# module "asg" {
#   source       = "./modules/aws/asg"
#   project_name = var.project_name
#   launch_template_ids = [
#     module.ec2.launch_templates["fe"],
#     module.ec2.launch_templates["be"],
#     module.ec2.launch_templates["ai-cpu"],
#   ]
#   # target_group_arns = [
#   #   module.alb.target_group_arn_fe,
#   #   module.nlb.target_group_arn_be
#   # ]
#   subnet_ids       = local.asg_k8s.subnet_ids
#   min_size         = local.asg_k8s.min_size
#   max_size         = local.asg_k8s.max_size
#   desired_capacity = local.asg_k8s.desired_capacity
# }


# module "ecr" {
#   source           = "./modules/aws/ecr"
#   project_name     = var.project_name
#   repository_names = var.ecr_repository_names
# }


# module "vpn" {
#   source = "./modules/aws/vpn"
#   subnet_ids = local.subnet_map
#   project_name                = var.project_name
#   vpc_cidr_block              = var.vpc_cidr_block
#   server_certificate_arn      = module.acm_vpn_server_req.certificate_arn
#   client_root_certificate_arn = module.acm_vpn_client_req.certificate_arn
#   client_cidr_block           = var.vpn_client_cidr_block
# }


# data "aws_lb" "ingress" {
#   name = "${var.project_name}-k8s-ingress"
#   depends_on = [module.fe_ingress]
# }

# module "cloudfront" {
#   source             = "./modules/aws/cloudfront"
#   origin_domain_name = data.aws_lb.ingress.dns_name
#   aliases            = [var.gcp_dns_domain_name]
#   certificate_arn    = module.acm_cloudfront_req.certificate_arn
#   web_acl_id         = module.waf.web_acl_arn
# }


# module "waf" {
#   source       = "./modules/aws/waf"
#   project_name = var.project_name
#   resource_arn = data.aws_lb.ingress.arn
# }



# module "acm_vpn_server_req" {
#   source                    = "./modules/aws/acm/request"
#   project_name              = var.project_name
#   domain_name               = var.vpn_server_domain
#   subject_alternative_names = []
#   tag                       = "vpn-server"
# }

# module "acm_vpn_client_req" {
#   source                    = "./modules/aws/acm/request"
#   project_name              = var.project_name
#   domain_name               = var.vpn_client_domain
#   subject_alternative_names = []
#   tag                       = "vpn-client"
# }

# module "acm_cloudfront_req" {
#   source                    = "./modules/aws/acm/request"
#   project_name              = var.project_name
#   domain_name               = var.gcp_dns_domain_name
#   subject_alternative_names = []
#   tag                       = "leafresh"
# }

# module "acm_alb_req" {
#   source                    = "./modules/aws/acm/request"
#   project_name              = var.project_name
#   domain_name               = var.gcp_dns_domain_name
#   subject_alternative_names = []
#   tag                       = "alb-ingress"
# }


# module "gcp_dns_server" {
#   source                    = "./modules/aws/dns"
#   project_id                = var.gcp_project_id
#   zone_name                 = var.gcp_dns_zone_name
#   domain_validation_options = module.acm_vpn_server_req.domain_validation_options
# }

# module "gcp_dns_client" {
#   source                    = "./modules/aws/dns"
#   project_id                = var.gcp_project_id
#   zone_name                 = var.gcp_dns_zone_name
#   domain_validation_options = module.acm_vpn_client_req.domain_validation_options
# }

# module "gcp_dns_cloudfront" {
#   source                    = "./modules/aws/dns"
#   project_id                = var.gcp_project_id
#   zone_name                 = var.gcp_dns_zone_name
#   domain_validation_options = module.acm_cloudfront_req.domain_validation_options
# }

# module "gcp_dns_alb" {
#   source                    = "./modules/aws/dns"
#   project_id                = var.gcp_project_id
#   zone_name                 = var.gcp_dns_zone_name
#   domain_validation_options = module.acm_alb_req.domain_validation_options
# }


# module "acm_server_val" {
#   source                  = "./modules/aws/acm/validate"
#   certificate_arn         = module.acm_vpn_server_req.certificate_arn
#   validation_record_fqdns = module.gcp_dns_server.fqdns
# }

# module "acm_client_val" {
#   source                  = "./modules/aws/acm/validate"
#   certificate_arn         = module.acm_vpn_client_req.certificate_arn
#   validation_record_fqdns = module.gcp_dns_client.fqdns
# }

# module "acm_cloudfront_val" {
#   source                  = "./modules/aws/acm/validate"
#   certificate_arn         = module.acm_cloudfront_req.certificate_arn
#   validation_record_fqdns = module.gcp_dns_cloudfront.fqdns
# }

# module "acm_alb_val" {
#   source                  = "./modules/aws/acm/validate"
#   certificate_arn         = module.acm_alb_req.certificate_arn
#   validation_record_fqdns = module.gcp_dns_alb.fqdns
# }


# module "lb_controller" {
#   source                  = "./modules/aws/lb_controller"
#   project_name            = var.project_name
#   cluster_oidc_url        = var.cluster_oidc_url
#   cluster_oidc_thumbprint = var.cluster_oidc_thumbprint
#   region                  = var.region
#   vpc_id                  = module.vpc.vpc_id
# }
