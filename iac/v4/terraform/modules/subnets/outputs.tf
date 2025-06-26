# modules/subnets/outputs.tf

output "public_subnets_map" {
  value = {
    for k, s in local.subnets_map :
    s.az => aws_subnet.this[k].id
    if s.is_public
  }
}

output "private_subnets_map" {
  value = {
    for k, s in local.subnets_map :
    s.az => aws_subnet.this[k].id
    if !s.is_public
  }
}

output "subnet_ids_by_suffix" {
  description = "Map of name_suffix → list of Subnet IDs across all AZs"
  value = {
    for cfg in var.subnet_configs :
    cfg.name_suffix => [
      for az in var.availability_zones :
      aws_subnet.this["${cfg.name_suffix}-${az}"].id
    ]
  }
}