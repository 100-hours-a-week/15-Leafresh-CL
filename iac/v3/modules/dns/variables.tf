variable "domain_name" { type = string }
variable "gcp_managed_zone" { type = string }
variable "alb_arn" { type = string }
variable "alb_dns_name" { type = string }
variable "default_target_group_arn" { type = string }
variable "ttl" { type = number }
variable "ssl_policy" {
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}
