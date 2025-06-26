# modules/rds/variables.tf

variable "project_name" {
  description = "The overall project name for resource naming."
  type        = string
}

variable "database_subnet_ids" {
  description = "A list of database subnet IDs for the RDS DB subnet group."
  type        = list(string)
}

variable "database_security_group_id" {
  description = "The ID of the security group to associate with the RDS instance."
  type        = string
}

variable "engine" {
  description = "The database engine to use (e.g., postgres, mysql)."
  type        = string
}

variable "engine_version" {
  description = "The database engine version."
  type        = string
}

variable "instance_class" {
  description = "The EC2 instance type for the RDS instance."
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
  type        = number
}

variable "storage_type" {
  description = "The storage type (e.g., gp2, gp3, io1)."
  type        = string
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
}

variable "multi_az" {
  description = "Specifies if the DB instance is a Multi-AZ deployment."
  type        = bool
}

variable "name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
}

variable "username" {
  description = "Username for the master DB user."
  type        = string
}

variable "password" {
  description = "Password for the master DB user."
  type        = string
  sensitive   = true # 민감한 정보이므로 true로 설정
}

variable "port" {
  description = "The port on which the DB accepts connections."
  type        = number
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
}

variable "backup_retention_period" {
  description = "The number of days to retain backups."
  type        = number
}
