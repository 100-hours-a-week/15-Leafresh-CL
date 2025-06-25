# modules/sqs/variables.tf

variable "project_name" {
  description = "The name of the project, used for SQS queue naming."
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)."
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to apply to the SQS queues."
  type        = map(string)
  default     = {}
}

# Order Queue specific variables (Main Queue)
variable "order_queue_delay_seconds" {
  description = "The length of time, in seconds, for which the delivery of all messages in the order queue is delayed."
  type        = number
}

variable "order_queue_max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it for the order queue."
  type        = number
}

variable "order_queue_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the order queue."
  type        = number
}

variable "order_queue_receive_wait_time_seconds" {
  description = "The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive in the order queue."
  type        = number
}

variable "order_queue_visibility_timeout_seconds" {
  description = "The length of time, in seconds, that a message is hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request in the order queue."
  type        = number
}

variable "order_queue_max_receive_count" {
  description = "The number of times a message is delivered to the source queue before being moved to the dead-letter queue."
  type        = number
}

# Order DLQ specific variables
variable "order_dlq_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the order DLQ."
  type        = number
}


# Send to AI Queue specific variables
variable "send_to_ai_queue_delay_seconds" {
  description = "The length of time, in seconds, for which the delivery of all messages in the send-to-AI queue is delayed."
  type        = number
}

variable "send_to_ai_queue_max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it for the send-to-AI queue."
  type        = number
}

variable "send_to_ai_queue_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the send-to-AI queue."
  type        = number
}

variable "send_to_ai_queue_receive_wait_time_seconds" {
  description = "The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive in the send-to-AI queue."
  type        = number
}

variable "send_to_ai_queue_visibility_timeout_seconds" {
  description = "The length of time, in seconds, that a message is hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request in the send-to-AI queue."
  type        = number
}

# Send to Backend Queue specific variables
variable "send_to_be_queue_delay_seconds" {
  description = "The length of time, in seconds, for which the delivery of all messages in the send-to-BE queue is delayed."
  type        = number
}

variable "send_to_be_queue_max_message_size" {
  description = "The limit of how many bytes a message can contain before Amazon SQS rejects it for the send-to-BE queue."
  type        = number
}

variable "send_to_be_queue_message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message in the send-to-BE queue."
  type        = number
}

variable "send_to_be_queue_receive_wait_time_seconds" {
  description = "The length of time, in seconds, for which a ReceiveMessage action waits for a message to arrive in the send-to-BE queue."
  type        = number
}

variable "send_to_be_queue_visibility_timeout_seconds" {
  description = "The length of time, in seconds, that a message is hidden from subsequent retrieve requests after being retrieved by a ReceiveMessage request in the send-to-BE queue."
  type        = number
}
