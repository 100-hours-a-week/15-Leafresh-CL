# modules/sqs/outputs.tf
output "queue_arns" {
  value = { for q, r in aws_sqs_queue.fifo : q => r.arn }
}

output "queue_urls" {
  value = { for q, r in aws_sqs_queue.fifo : q => r.id }
}

output "dlq_arns" {
  value = { for q, r in aws_sqs_queue.dlq : q => r.arn }
}

output "dlq_urls" {
  value = { for q, r in aws_sqs_queue.dlq : q => r.id }
}
