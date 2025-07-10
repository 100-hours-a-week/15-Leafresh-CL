variable "project_name" { type = string }
variable "vpc_id" { type = string }
variable "region" { type = string }
variable "access_key_id" { type = string }
variable "secret_access_key" { type = string }
variable "create_s3_uploader_iam" { type = bool }
variable "ec2_nodes" {
  type = list(object({
    name          = string
    ami           = string
    instance_type = string
    subnet_id     = string
    role          = string
  }))
}
