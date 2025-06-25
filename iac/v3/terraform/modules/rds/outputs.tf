# modules/rds/outputs.tf

output "db_instance_endpoint" {
  description = "The connection endpoint of the RDS instance."
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "The port of the RDS instance."
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "The database name of the RDS instance."
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "The master username of the RDS instance."
  value       = aws_db_instance.main.username
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group."
  value       = aws_db_subnet_group.main.name
}
