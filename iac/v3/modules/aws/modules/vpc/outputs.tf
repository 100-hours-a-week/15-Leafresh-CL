# modules/vpc/outputs.tf
output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "igw_id" {
  value = aws_internet_gateway.igw.id
}