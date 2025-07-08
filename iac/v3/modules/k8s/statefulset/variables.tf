variable "name" { type = string }
variable "namespace" { type = string }
variable "service_name" { type = string }
variable "replicas" { type = number }
variable "container_image" { type = string }
variable "container_port" { type = number }
variable "config_map_name" { type = string }