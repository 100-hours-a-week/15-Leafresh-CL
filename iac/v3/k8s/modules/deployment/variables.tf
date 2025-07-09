variable "name" { type = string }
variable "namespace" { type = string }
variable "image" { type = string }
variable "port" { type = number }
variable "replicas" { type = number }
variable "node_selector" {
  type    = map(string)
  default = {}
}