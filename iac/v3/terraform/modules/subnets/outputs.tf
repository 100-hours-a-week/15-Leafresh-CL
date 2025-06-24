# modules/subnets/outputs.tf
output "subnet_ids" {
  description = "A map of subnet IDs by AZ."
  value       = { for az, subnet in aws_subnet.this : az => subnet.id }
}

output "subnet_arns" {
  description = "A map of subnet ARNs by AZ."
  value       = { for az, subnet in aws_subnet.this : az => subnet.arn }
}
