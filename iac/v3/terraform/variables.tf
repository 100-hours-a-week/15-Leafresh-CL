# variables.tf (Root Module)
variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = "MyArchitectureVPC"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/18)."
  type        = string
  default     = "10.0.0.0/18"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster to tag subnets for."
  type        = string
  default     = "my-eks-cluster"
}

variable "availability_zones" {
  description = "List of availability zones to deploy resources into."
  type        = list(string)
  default = [
    "ap-northeast-2a",
    "ap-northeast-2b"
  ]
}

# Define the base /19 CIDR block for each AZ, derived from the /18 VPC.
# This assumes the VPC is always /18 and AZs split it into /19s.
variable "az_base_cidrs" {
  description = "Map of AZ to its base /19 CIDR block within the VPC."
  type        = map(string)
  default = {
    "ap-northeast-2a" = "10.0.0.0/19"
    "ap-northeast-2b" = "10.0.32.0/19"
  }
  # You could also calculate this dynamically if your VPC CIDR might change:
  # value = {
  #   "ap-northeast-2a" = cidrsubnet(var.vpc_cidr_block, 19, 0)
  #   "ap-northeast-2b" = cidrsubnet(var.vpc_cidr_block, 19, 1)
  # }
}


# These are the offsets *within* each AZ's /19 block.
# We need to ensure these offsets are valid given the `prefix_length` (e.g., newbits).
# Calculate the number of smaller blocks a /19 can be split into:
# For /22: 2^(22-19) = 2^3 = 8 subnets (offsets 0-7)
# For /20: 2^(20-19) = 2^1 = 2 subnets (offsets 0-1)
# For /23: 2^(23-19) = 2^4 = 16 subnets (offsets 0-15)
# For /24: 2^(24-19) = 2^5 = 32 subnets (offsets 0-31)

variable "subnet_offsets" {
  description = "Map of subnet type to its offset within the AZ's base /19 CIDR block. These are sequential indexes."
  type        = map(number)
  default = {
    # Public subnet: /22. `newbits` = 22-19 = 3. Max offset = 2^3 - 1 = 7.
    # Start at 0: 10.0.0.0/22 (from 10.0.0.0/19)
    public       = 0

    # EKS subnet: /20. `newbits` = 20-19 = 1. Max offset = 2^1 - 1 = 1.
    # To place it after public (which uses 10.0.0.0/22, 10.0.4.0/22, 10.0.8.0/22, 10.0.12.0/22)
    # The smallest /20 block starts at offset 0 (10.0.0.0/20) or offset 1 (10.0.16.0/20).
    # Since public is 10.0.0.0/22, which is part of 10.0.0.0/20, EKS must start after that.
    # Let's allocate 10.0.16.0/20 for EKS. This means offset 1 for /20.
    eks          = 1

    # Data subnet: /23. `newbits` = 23-19 = 4. Max offset = 2^4 - 1 = 15.
    # Public (10.0.0.0/22) consumes 10.0.0.0-10.0.3.255.
    # EKS (10.0.16.0/20) consumes 10.0.16.0-10.0.31.255.
    # Remaining from 10.0.0.0/19 (10.0.0.0-10.0.31.255): 10.0.4.0-10.0.15.255
    # Let's use `10.0.4.0/23`. This corresponds to offset 2 for /23 subnets.
    # (10.0.0.0/23 is offset 0, 10.0.2.0/23 is offset 1, 10.0.4.0/23 is offset 2)
    data         = 2

    # App subnet: /23. Next available after data.
    # 10.0.6.0/23 corresponds to offset 3.
    app          = 3

    # Ops subnet: /24. `newbits` = 24-19 = 5. Max offset = 2^5 - 1 = 31.
    # 10.0.8.0/24 corresponds to offset 4.
    ops          = 4

    # Monitoring subnet: /24. Next available after ops.
    # 10.0.9.0/24 corresponds to offset 5.
    monitoring   = 5

    # Reserved subnet: /22. `newbits` = 22-19 = 3. Max offset = 2^3 - 1 = 7.
    # 10.0.12.0/22 corresponds to offset 3.
    # This might overlap with previous if offsets are small for large blocks.
    # Let's ensure these offsets are genuinely sequential and non-overlapping based on the *actual CIDRs*.
    # A more robust way is to use `cidrsubnets` or `for` loops to assign:

    # Let's calculate the `offset` for `cidrsubnet(10.0.0.0/19, new_prefix, offset)`:
    # Public (/22): 10.0.0.0/22. Offset: 0. (uses /22)
    # EKS (/20): 10.0.16.0/20. Offset: 1. (uses /20)
    # Data (/23): 10.0.4.0/23. Offset: 2. (uses /23)
    # App (/23): 10.0.6.0/23. Offset: 3. (uses /23)
    # Ops (/24): 10.0.8.0/24. Offset: 4. (uses /24)
    # Monitoring (/24): 10.0.9.0/24. Offset: 5. (uses /24)
    # Reserved (/22): 10.0.12.0/22. Offset: 3. (uses /22)

    # Let's re-align the `subnet_offsets` values to be correct relative to the /19 base.
    # We need to manually calculate the appropriate `netnum` for each.
    # For AZ 'a' (base 10.0.0.0/19):
    # Public (/22): `cidrsubnet("10.0.0.0/19", 22, 0)` -> 10.0.0.0/22
    # EKS (/20): `cidrsubnet("10.0.0.0/19", 20, 1)` -> 10.0.16.0/20
    # Data (/23): `cidrsubnet("10.0.0.0/19", 23, 2)` -> 10.0.4.0/23
    # App (/23): `cidrsubnet("10.0.0.0/19", 23, 3)` -> 10.0.6.0/23
    # Ops (/24): `cidrsubnet("10.0.0.0/19", 24, 8)` -> 10.0.8.0/24 (Offset 8 for /24)
    # Monitoring (/24): `cidrsubnet("10.0.0.0/19", 24, 9)` -> 10.0.9.0/24 (Offset 9 for /24)
    # Reserved (/22): `cidrsubnet("10.0.0.0/19", 22, 3)` -> 10.0.12.0/22

    public       = 0  # 10.0.0.0/22 (from 10.0.0.0/19)
    eks          = 1  # 10.0.16.0/20 (from 10.0.0.0/19)
    data         = 2  # 10.0.4.0/23 (from 10.0.0.0/19)
    app          = 3  # 10.0.6.0/23 (from 10.0.0.0/19)
    ops          = 4  # 10.0.8.0/24 (from 10.0.0.0/19)
    monitoring   = 5  # 10.0.9.0/24 (from 10.0.0.0/19)
    reserved     = 3  # 10.0.12.0/22 (from 10.0.0.0/19)
  }
}

variable "subnet_prefixes" {
  description = "Map of subnet type to its CIDR prefix length."
  type        = map(number)
  default = {
    public       = 22
    eks          = 20
    data         = 23
    app          = 23
    ops          = 24
    monitoring   = 24
    reserved     = 22
  }
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks that are allowed to SSH into instances."
  type        = list(string)
  # !!! 중요: 실제 환경에서는 이곳을 외부에서 SSH 접속이 필요한 특정 IP 대역으로 제한해야 합니다.
  # 예: ["203.0.113.0/24"] 또는 여러분의 사무실/VPN IP
  default     = ["0.0.0.0/0"] # 경고: 이 설정은 모든 IP에서 SSH를 허용하므로 프로덕션 환경에서는 절대 사용하지 마십시오.
}
