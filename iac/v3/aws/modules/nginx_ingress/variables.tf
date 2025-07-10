variable "project_name" {
  description = "Project name"
  type        = string
  default     = "leafresh"
}

variable "name" {
  description = "Helm release name"
  type        = string
  default     = "nginx-ingress"
}

variable "repository" {
  description = "Helm chart repo URL"
  type        = string
  default     = "https://kubernetes.github.io/ingress-nginx"
}

variable "chart" {
  description = "Helm chart name"
  type        = string
  default     = "ingress-nginx"
}

variable "namespace" {
  description = "Kubernetes namespace for the release"
  type        = string
  default     = "ingress-nginx"
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "service_type" {
  description = "Kubernetes Service type (LoadBalancer, ClusterIP 등)"
  type        = string
  default     = "LoadBalancer"
}

variable "load_balancer_type" {
  description = "AWS LoadBalancer 타입 (nlb 또는 alb)"
  type        = string
  default     = "nlb"
}

variable "publish_service_enabled" {
  description = "controller.publishService.enabled 설정"
  type        = bool
  default     = true
}
