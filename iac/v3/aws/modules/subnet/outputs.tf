# modules/subnet/outputs.tf

output "public_subnet_ids" {
  value = [for k in aws_subnet.public : k.id]
}

output "private_subnet_ids" {
  value = [for k in aws_subnet.private : k.id]
}

output "private_subnet_ids_map" {
  value = { for key, sn in aws_subnet.private : key => sn.id }
}