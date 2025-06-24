# modules/security_groups/variables.tf
variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC (e.g., 10.0.0.0/18)."
  type        = string
}

variable "name_prefix" {
  description = "A prefix for naming security groups."
  type        = string
  default     = "sg" # 기본 접두사
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks that are allowed to SSH into instances."
  type        = list(string)
  default     = ["0.0.0.0/0"] # 실제 환경에서는 특정 IP/CIDR로 제한해야 합니다.
}

variable "additional_tags" {
  description = "Additional tags to apply to the security groups."
  type        = map(string)
  default     = {}
}

variable "enable_app_server_sg" {
  description = "Controls whether the application server security group is enabled and its related rules are created."
  type        = bool
  default     = true # Set to true to create these rules by default
}

variable "enable_ops_tools_sg" {
  description = "Controls whether the operations tools security group is enabled and its related rules are created."
  type        = bool
  default     = true # Set to true to create these rules by default
}
