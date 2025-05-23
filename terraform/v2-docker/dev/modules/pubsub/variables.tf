# modules/pubsub/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "project_number" {
  description = "GCP 프로젝트 번호"
  type        = string
  # default     = "" # Terraform apply 시 자동으로 채워짐
}
