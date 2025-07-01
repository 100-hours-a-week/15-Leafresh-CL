variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "instance_id_k8s_worker_fe" { type = string }
variable "instance_id_monitoring"     { type = string }
variable "instance_id_argocd"         { type = string }