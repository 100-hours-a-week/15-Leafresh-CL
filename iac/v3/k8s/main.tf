# main.tf
data "terraform_remote_state" "leafresh" {
  backend = "local"

  config = {
    path = "${path.module}/../aws/terraform.tfstate"  # 또는 절대경로 사용
  }
}


# k8s modules
# =====================================================================
module "ns_frontend" {
  source    = "./modules/namespace"
  namespace = "frontend"
}
module "fe" {
  source    = "./modules/deployment"
  name      = "fe"
  namespace = module.ns_frontend.namespace
  image     = "${data.terraform_remote_state.leafresh.outputs.ecr_urls["ecr"]}/frontend-develop:latest"
  port      = 5173
  replicas  = 1
}

module "fe_svc" {
  source      = "./modules/service"
  name        = "fe-service"
  namespace   = module.ns_frontend.namespace
  port        = 80
  target_port = 5173
  type        = "ClusterIP"
}
module "fe_ingress" {
  source              = "./modules/ingress"
  name                = "${var.project_name}-k8s-ingress"
  namespace           = module.ns_frontend.namespace
  domain_name         = var.gcp_dns_domain_name
  service_name        = module.fe_svc.name
  service_port        = module.fe_svc.port
  kubeconfig_path     = var.kubeconfig_path
  alb_certificate_arn = data.terraform_remote_state.leafresh.outputs.certificate_arn
}


module "ns_backend" {
  source    = "./modules/namespace"
  namespace = "backend"
}
module "be" {
  source    = "./modules/deployment"
  name      = "be"
  namespace = module.ns_backend.namespace
  image     = "${data.terraform_remote_state.leafresh.outputs.ecr_urls["ecr"]}/backend-develop:latest"
  port      = 3000
  replicas  = 1
}
module "be_svc" {
  source      = "./modules/service"
  name        = "be-service"
  namespace   = module.ns_backend.namespace
  port        = 80
  target_port = 3000
  type        = "LoadBalancer"
}


module "ns_ai" {
  source    = "./modules/namespace"
  namespace = "ai"
}

module "ai" {
  source    = "./modules/deployment"
  name      = "ai"
  namespace = module.ns_ai.namespace
  image     = "${data.terraform_remote_state.leafresh.outputs.ecr_urls["ecr"]}/ai-develop:latest"
  port      = 8000
  replicas  = 1
}

module "ai_svc" {
  source      = "./modules/service"
  name        = "ai-service"
  namespace   = module.ns_ai.namespace
  port        = 8000
  target_port = 8000
  type        = "LoadBalancer"
}


module "ns_redis" {
  source    = "./modules/namespace"
  namespace = "redis"
}

module "redis_cfg" {
  source    = "./modules/configmap"
  name      = "redis-config"
  namespace = module.ns_redis.namespace
  data = {
    "redis.conf" = file("${path.module}/modules/templates/redis.conf")
  }
}

module "redis_master" {
  source          = "./modules/statefulset"
  name            = "redis-master"
  namespace       = module.ns_redis.namespace
  service_name    = "redis-master"
  replicas        = 1
  container_image = "redis:7.4"
  container_port  = 6379
  config_map_name = module.redis_cfg.name
}

module "redis_slave" {
  source          = "./modules/statefulset"
  name            = "redis-slave"
  namespace       = module.ns_redis.namespace
  service_name    = "redis-slave"
  replicas        = 1
  container_image = "redis:7.4"
  container_port  = 6379
  config_map_name = module.redis_cfg.name
}

module "redis_master_svc" {
  source      = "./modules/service"
  name        = "redis-master"
  namespace   = module.ns_redis.namespace
  port        = 6379
  target_port = 6379
  type        = "ClusterIP"
}

module "redis_slave_svc" {
  source      = "./modules/service"
  name        = "redis-slave"
  namespace   = module.ns_redis.namespace
  port        = 6379
  target_port = 6379
  type        = "ClusterIP"
}


module "ns_monitoring" {
  source    = "./modules/namespace"
  namespace = "monitoring"
}

module "prometheus" {
  source    = "./modules/deployment"
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
  source      = "./modules/service"
  name        = "prometheus"
  namespace   = module.ns_monitoring.namespace
  port        = 9090
  target_port = 9090
  type        = "ClusterIP"
}

module "loki" {
  source    = "./modules/deployment"
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
  source      = "./modules/service"
  name        = "loki"
  namespace   = module.ns_monitoring.namespace
  port        = 3100
  target_port = 3100
  type        = "ClusterIP"
}

module "grafana" {
  source    = "./modules/deployment"
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
  source      = "./modules/service"
  name        = "grafana"
  namespace   = module.ns_monitoring.namespace
  port        = 3000
  target_port = 3000
  type        = "LoadBalancer"
}

module "jaeger" {
  source    = "./modules/deployment"
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
  source      = "./modules/service"
  name        = "jaeger"
  namespace   = module.ns_monitoring.namespace
  port        = 16686
  target_port = 16686
  type        = "ClusterIP"
}

module "monitor_ingress" {
  source              = "./modules/ingress"
  name                = "monitoring-ingress"
  namespace           = module.ns_monitoring.namespace
  domain_name         = "monitor.leafresh.app"
  service_name        = module.grafana_svc.name
  service_port        = module.grafana_svc.port
  alb_certificate_arn = data.terraform_remote_state.leafresh.outputs.certificate_arn
  kubeconfig_path     = var.kubeconfig_path
}
