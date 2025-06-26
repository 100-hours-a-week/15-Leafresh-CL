# modules/s3/variables.tf

variable "project_name" {
  description = "The name of the project, used for bucket naming (e.g., leafresh)."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
}
