variable "origin_domain_name" { type = string }
variable "aliases" { type = list(string) }
variable "certificate_arn" { type = string }
variable "web_acl_id" { type = string }