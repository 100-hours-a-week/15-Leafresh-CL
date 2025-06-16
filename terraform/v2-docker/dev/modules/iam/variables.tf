variable "project_id_dev" {
  description = "GCP Project ID"
  type        = string
}

variable "gcs_bucket_names" {
  description = "A map of GCS bucket names to apply IAM bindings to."
  type        = map(string)
}

variable "iam_project_bindings" {
  description = "프로젝트 권한과 멤버 바인딩"
  type = list(object({
    role   = string
    members = list(string)
  }))
}

variable "iam_storage_bindings_per_bucket" {
  description = "A map where keys are GCS bucket config keys and values are lists of IAM bindings for that bucket."
  type = map(list(object({
    role    = string
    members = list(string)
  })))
}