variable "storage_name" {
  description = "GCS bucket name"
  type        = string
}

variable "project_id_dev" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "Bucket region"
  type        = string
}

variable "storage_class" {
  description = "Storage class"
  type        = string
  default     = "STANDARD"
}

variable "storage_force_destroy" {
  description = "Force delete bucket and its contents"
  type        = bool
  default     = false
}

# CORS 설정
variable "storage_cors_origin" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "storage_cors_method" {
  description = "Allowed CORS HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD", "PUT", "POST", "DELETE"]
}

variable "storage_cors_response_header" {
  description = "Allowed response headers"
  type        = list(string)
  default     = ["*"]
}

variable "storage_cors_max_age_seconds" {
  description = "Max age for CORS options"
  type        = number
  default     = 3600
}
