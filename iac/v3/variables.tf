# variables.tf


# default variables
# =====================================================================
variable "project_name" {
  description = "Project name"
  type        = string
  default     = "leafresh"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}



# tag variables
# =====================================================================
variable "tag_environment" {
  description = "Runnung Environment as tag"
  type        = string
  default     = "Dev"
}



# vpc variables
# =====================================================================
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/18)."
  type        = string
  default     = "10.0.0.0/16"
}



# subnet variables
# =====================================================================
variable "public_subnet_cidrs" {
  description = "Map of AZ suffixes to public subnet CIDRs"
  type        = map(string)
  default = {
    a = "10.0.1.0/24"
    c = "10.0.101.0/24"
  }
}

variable "private_subnet_cidrs" {
  description = "Map of AZ-suffix-index to private subnet CIDRs (e.g. a-1)"
  type        = map(string)
  default = {
    "a-1" = "10.0.2.0/24"
    "a-2" = "10.0.3.0/24"
    "c-1" = "10.0.102.0/24"
    "c-2" = "10.0.103.0/24"
  }
}



# S3 variables
# =====================================================================
variable "s3_bucket_suffixes" {
  description = "List of suffixes for S3 buckets"
  type        = list(string)
  default     = ["images", "prod-images", "logs"]
}



# RDS variables
# =====================================================================
variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "root"
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  default     = "Rlatldms!2!3"
  sensitive   = true
}

variable "db_instance" {
  description = "Instance class for the RDS instance"
  type        = string
  default     = "db.m5.xlarge"
}

variable "db_engine" {
  description = "Instance engine for the RDS instance"
  type        = string
  default     = "mysql"
}

variable "db_engine_version" {
  description = "Instance engine version for the RDS instance"
  type        = string
  default     = "8.0"
}

variable "db_storage_type" {
  description = "Storage type for the RDS instance"
  type        = string
  default     = "gp3"
}

variable "db_multi_az" {
  description = "Multi AZ setting for the RDS instance"
  type        = bool
  default     = false
}



# SQS variables
# =====================================================================
variable "sqs_fifo_queue_names" {
  description = "List of FIFO SQS queue suffixes"
  type        = list(string)
  default     = ["order", "images"]
}

variable "sqs_fifo_dlq_queue_names" {
  description = "List of FIFO SQS queues that require DLQ"
  type        = list(string)
  default     = ["order"]
}

variable "sqs_fifo_max_receive_count" {
  description = "MaxReceiveCount for DLQ redrive policy"
  type        = number
  default     = 5
}