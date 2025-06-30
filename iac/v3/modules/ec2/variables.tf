variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "region" { type = string }
variable "ec2_nodes" {
  type = list(object({
    name          = string
    ami           = string
    instance_type = string
    subnet_id     = string
    role          = string
  }))
}
