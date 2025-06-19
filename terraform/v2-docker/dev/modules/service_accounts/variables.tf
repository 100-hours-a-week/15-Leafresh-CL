# modules/service_accounts/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "service_accounts" {
  description = "생성할 서비스 계정과 부여할 역할 목록"
  type = list(object({
    account_id   = string
    display_name = string
    roles        = list(string)
  }))
}

