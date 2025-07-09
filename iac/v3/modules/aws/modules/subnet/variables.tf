# modules/subnet/variables.tf

variable "project_name" { type = string }
variable "region" { type = string }
variable "vpc_id" { type = string }
variable "igw_id" { type = string }
variable "public_subnet_cidrs" { type = map(string) }
variable "private_subnet_cidrs" { type = map(string) }