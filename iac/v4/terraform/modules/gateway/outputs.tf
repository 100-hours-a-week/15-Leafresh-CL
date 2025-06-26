# modules/gateway/outputs.tf
output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "natgw_map" {
  description = "Map of subnet_key → NAT Gateway ID"
  value       = { for k, ngw in aws_nat_gateway.this : k => ngw.id }
}
