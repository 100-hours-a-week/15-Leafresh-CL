# modules/gateway/variables.tf
variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC for naming conventions."
  type        = string
}

variable "public_subnet_ids" {
  description = "A map of public subnet IDs (key=AZ, value=ID) to create NAT Gateways in."
  type        = map(string)
}
