variable "project_id_dev" {
  description = "GCP Project ID"
  type        = string
}

variable "iam_bindings" {
  description = "권한과 멤버 바인딩"
  type = list(object({
    role   = string
    member = string
  }))
}

