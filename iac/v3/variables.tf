# variables.tf


# default variables
# =====================================================================
variable "project_name" {
    description = "Project name"
    type = string
    default = "leafresh"
}



# tag variables
# =====================================================================
variable "tag_environment" {
    description = "Runnung Environment as tag"
    type = string
    default = "Dev"
}



# vpc variables
# =====================================================================
variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "leafresh-vpc"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/18)."
  type        = string
  default     = "10.0.0.0/18"
}