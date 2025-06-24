# modules/vpc/variables.tf
variable "name" {
  description = "The name of the VPC."
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}
