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

variable "kubeconfig_path" {
  description = "Config file of k8s"
  type        = string
  default     = "/home/ubuntu/.kube/config"
}

variable "tag_environment" {
  description = "Runnung Environment as tag"
  type        = string
  default     = "Dev"
}
