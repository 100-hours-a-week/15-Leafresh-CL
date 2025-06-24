# modules/gateway/outputs.tf
output "igw_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "natgw_ids" {
  description = "A map of NAT Gateway IDs by AZ."
  value       = { for az, gw in aws_nat_gateway.this : az => gw.id }
}
