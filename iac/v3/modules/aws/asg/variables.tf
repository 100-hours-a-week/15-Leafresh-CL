variable "project_name" { type = string }
variable "launch_template_ids" { type = list(string) }
variable "subnet_ids" { type = list(string) }
# variable "target_group_arns" { type = list(string) }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "desired_capacity" { type = number }
