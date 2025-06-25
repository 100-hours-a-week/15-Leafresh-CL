# modules/s3/variables.tf

variable "project_name" {
  description = "The name of the project, used for bucket naming (e.g., leafresh)."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to the S3 buckets."
  type        = map(string)
  default     = {} # 이 모듈 내에서 기본값이지만, 루트에서 오버라이드 가능
}
