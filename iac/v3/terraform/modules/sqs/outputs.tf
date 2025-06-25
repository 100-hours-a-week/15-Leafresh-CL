# modules/sqs/outputs.tf

output "order_queue_name" {
  description = "The name of the SQS main queue for order processing."
  value       = aws_sqs_queue.order_queue.name
}

output "order_queue_url" {
  description = "The URL of the SQS main queue for order processing."
  value       = aws_sqs_queue.order_queue.id
}

output "order_queue_arn" {
  description = "The ARN of the SQS main queue for order processing."
  value       = aws_sqs_queue.order_queue.arn
}

output "order_dlq_queue_name" {
  description = "The name of the SQS Dead-Letter Queue for order processing."
  value       = aws_sqs_queue.order_dlq_queue.name
}

output "order_dlq_queue_url" {
  description = "The URL of the SQS Dead-Letter Queue for order processing."
  value       = aws_sqs_queue.order_dlq_queue.id
}

output "order_dlq_queue_arn" {
  description = "The ARN of the SQS Dead-Letter Queue for order processing."
  value       = aws_sqs_queue.order_dlq_queue.arn
}

output "send_to_ai_queue_name" {
  description = "The name of the SQS queue for sending messages to AI service."
  value       = aws_sqs_queue.send_to_ai_queue.name
}

output "send_to_ai_queue_url" {
  description = "The URL of the SQS queue for sending messages to AI service."
  value       = aws_sqs_queue.send_to_ai_queue.id
}

output "send_to_ai_queue_arn" {
  description = "The ARN of the SQS queue for sending messages to AI service."
  value       = aws_sqs_queue.send_to_ai_queue.arn
}

output "send_to_be_queue_name" {
  description = "The name of the SQS queue for sending messages to Backend service."
  value       = aws_sqs_queue.send_to_be_queue.name
}

output "send_to_be_queue_url" {
  description = "The URL of the SQS queue for sending messages to Backend service."
  value       = aws_sqs_queue.send_to_be_queue.id
}

output "send_to_be_queue_arn" {
  description = "The ARN of the SQS queue for sending messages to Backend service."
  value       = aws_sqs_queue.send_to_be_queue.arn
}
