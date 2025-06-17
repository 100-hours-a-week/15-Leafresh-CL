variable "project_id_dev" {
  description = "GCP Project ID"
  type        = string
}

variable "service_account_bindings" {
  description = "서비스 계정 바인딩(member+roles) 리스트"
  type = list(object({
    member = string
    roles  = list(string)
  }))
}

variable "user_accounts" {
  description = "사용자 계정 바인딩(member+roles) 리스트"
  type = list(object({
    member = string
    roles  = list(string)
  }))
}

variable "iam_storage_bindings_per_bucket" {
  description = "버킷 키별로 부여할 IAM 역할·멤버 리스트"
  type = map(list(object({
    role    = string
    members = list(string)
  })))
}

variable "gcs_bucket_names" {
  description = "실제 버킷 이름 맵"
  type        = map(string)
}

