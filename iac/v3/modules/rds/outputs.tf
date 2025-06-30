# modules/rds/outputs.tf
output "instance_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "instance_id" {
  value = aws_db_instance.this.id
}