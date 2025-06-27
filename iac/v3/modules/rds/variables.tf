# modules/rds/variables.tf
variable "project_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}
variable "storage_type" { type = string }
variable "instance_class" { type = string }
variable "engine" { type = string }
variable "engine_version" { type = string }
variable "identifier" { type = string }
variable "multi_az" { type = bool }