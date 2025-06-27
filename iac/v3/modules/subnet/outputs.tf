# modules/subnet/outputs.tf

output "public_subnet_ids" {
  value = { for k, s in aws_subnet.public : k => s.id }
}

output "private_subnet_ids" {
  value = { for k, s in aws_subnet.private : k => s.id }
}
