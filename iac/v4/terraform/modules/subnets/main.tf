# modules/subnets/main.tf

locals {
  vpc_mask = tonumber(split("/", var.vpc_cidr_block)[1])
  az_count = length(var.availability_zones)

  # pick the smallest n where 2^n ≥ az_count
  az_bits = [for n in range(0, 8) : n if pow(2, n) >= local.az_count][0]

  subnets_to_create = flatten([
    for cfg in var.subnet_configs : [
      for az_index, az in var.availability_zones : {
        key        = "${cfg.name_suffix}-${az}"
        name       = "${var.vpc_name}-${cfg.name_suffix}-${az}"
        az         = az

        cidr_block = cidrsubnet(
          cidrsubnet(
            var.vpc_cidr_block,
            cfg.prefix_length - local.vpc_mask,
            cfg.cidr_offset,
          ),
          local.az_bits,
          az_index,
        )

        is_public               = cfg.type == "public"
        map_public_ip_on_launch = cfg.map_public_ip_on_launch
        tags = {
          Name = "${var.vpc_name}-subnet-${cfg.name_suffix}-${az}"
          AZ   = az
        }
      }
    ]
  ])

  subnets_map = { for s in local.subnets_to_create : s.key => s }
}


resource "aws_subnet" "this" {
  for_each                = local.subnets_map
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    Name = each.value.tags.Name
    AZ   = each.value.tags.AZ
  }
}
