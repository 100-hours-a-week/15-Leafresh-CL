# modules/pubsub/variables.tf

variable "project_id" {
  description = "GCP 프로젝트 ID"
  type        = string
}

variable "project_number" {
  description = "GCP 프로젝트 번호"
  type        = string
}

variable "pubsub_topic_names" {
  type = map(object({
    subscription_name = string
  }))
  description = "pub/sub topics and subscriptions"
}
