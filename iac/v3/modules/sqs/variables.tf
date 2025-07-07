# modules/sqs/variables.tf
variable "project_name" { type = string }
variable "queue_names" { type = list(string) }
variable "dlq_queue_names" { type = list(string) }
variable "max_receive_count" { type = number }
