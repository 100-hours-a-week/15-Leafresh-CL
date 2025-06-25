# modules/subnets/outputs.tf
output "subnet_ids" {
  description = "A map of subnet IDs by AZ."
  value       = { for az, subnet in aws_subnet.this : az => subnet.id }
}

output "subnet_arns" {
  description = "A map of subnet ARNs by AZ."
  value       = { for az, subnet in aws_subnet.this : az => subnet.arn }
}

#output "private_app_subnet_ids" {
#  description = "List of IDs of the private application subnets."
#  value       = aws_subnet.private_app.*.id # 또는 실제 private app subnet의 리소스 이름
#}
