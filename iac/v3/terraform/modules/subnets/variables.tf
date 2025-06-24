# modules/subnets/variables.tf
variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones for subnets."
  type        = list(string)
}

variable "base_az_cidr_block" { # This will be the /19 for each AZ
  description = "Map of AZ to its base CIDR block (e.g., 10.0.0.0/19 for ap-northeast-2a)."
  type        = map(string)
}

variable "offset" { # This is the offset within the /19 AZ block
  description = "The numeric offset for this specific subnet type within its AZ's base CIDR."
  type        = number
}

variable "prefix_length" {
  description = "The prefix length of the subnet CIDR block (e.g., 22, 23, 24)."
  type        = number
}

variable "name_prefix" {
  description = "Prefix for the subnet name (e.g., 'Public', 'Private-EKS')."
  type        = string
}

variable "map_public_ip_on_launch" {
  description = "Whether to map public IP on launch (true for public subnets)."
  type        = bool
  default     = false
}

variable "needs_route_table" {
  description = "Whether this subnet type needs a dedicated route table."
  type        = bool
  default     = true
}

variable "is_public" {
  description = "Whether this is a public subnet (determines IGW vs NAT GW routing)."
  type        = bool
  default     = false
}

variable "internet_gateway_id" {
  description = "The ID of the Internet Gateway. Required if is_public is true."
  type        = string
  default     = null
}

variable "nat_gateway_ids" {
  description = "Map of AZ to NAT Gateway ID. Required if is_public is false and needs_route_table is true."
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to apply to the subnets. Useful for EKS-specific tags."
  type        = map(string)
  default     = {}
}
