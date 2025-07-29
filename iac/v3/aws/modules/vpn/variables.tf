variable "project_name" { type = string }
variable "subnet_ids" { type = map(string) }
variable "vpc_cidr_block" { type = string }
# variable "server_certificate_arn" { type = string }
# variable "client_root_certificate_arn" { type = string }
variable "client_cidr_block" { type = string }
