# modules/pubsub/variables.tf

variable "project_id_dev" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "project_number" {
  description = "GCP 프로젝트 번호"
  type        = string
}

variable "pubsub_topic_name" {
  description = "GCP 토픽 이름"
  type        = string
  default     = "leafresh-pubsub-be-topic"
}

variable "pubsub_subscription_name" {
  description = "GCP 구독 이름"
  type        = string
  default     = "leafresh-pubsub-be-subscription"
}