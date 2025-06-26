# modules/subnets/variables.tf

variable "vpc_id" {
  description = "The ID of the VPC to create subnets in."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC."
  type        = string
}

variable "availability_zones" {
  description = "A list of availability zones to deploy subnets across."
  type        = list(string)
}

variable "vpc_name" {
  description = "The overall vpc name for resource naming."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "subnet_configs" {
  description = "A list of objects defining the configuration for each type of subnet."
  type = list(object({
    name_suffix             = string                # 예: "Web-Public", "App-Private", "Data-Private"
    type                    = string                # "public" 또는 "private"
    cidr_offset             = number                # VPC CIDR 블록 내에서 서브넷 CIDR을 계산하기 위한 오프셋
    prefix_length           = number                # 서브넷의 CIDR 접두사 길이 (예: 24, 20)
    map_public_ip_on_launch = bool # public 서브넷의 경우 true로 설정
  }))
}