variable "domain_name" { type = string }
variable "project_name" { type = string }
variable "tag" { type = string }
variable "subject_alternative_names" {
  type    = list(string)
  default = []
}