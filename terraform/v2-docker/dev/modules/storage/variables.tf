# modules/gcs_buckets/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "region" {
  description = "Bucket region"
  type        = string
}

variable "buckets_config" {
  description = "A map of configurations for multiple GCS buckets."
  type = map(object({
    name              = string
    storage_class     = string
    force_destroy     = bool
    environment_label = string
    purpose_label     = string
    cors_config = object({
      origin          = list(string)
      method          = list(string)
      response_header = list(string)
      max_age_seconds = number
    })
  }))
}
