# modules/gateway/variables.tf
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_name" {
  description = "Used for naming (tags)"
  type        = string
}

variable "public_subnet_ids" {
  description = "Map of subnet_key → Public Subnet ID"
  type        = map(string)
}

variable "private_subnet_ids" {
  description = "Map of subnet_key → Private Subnet ID"
  type        = map(string)
}