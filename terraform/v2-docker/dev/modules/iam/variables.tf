variable "project_id_dev" {
  description = "GCP Project ID"
  type        = string
}

variable "iam_bindings" {
  description = "프로젝트 권한과 멤버 바인딩"
  type = list(object({
    role   = string
    member = string
  }))
}

variable "storage_name" {
  description = "스토리지 이름"
  type        = string
}