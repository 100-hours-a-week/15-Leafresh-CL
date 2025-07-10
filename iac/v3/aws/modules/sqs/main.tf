# modules/sqs/main.tf
# DLQs
resource "aws_sqs_queue" "dlq" {
  for_each                    = toset(var.dlq_queue_names)
  name                        = "${var.project_name}-sqs-${each.value}-dlq.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  tags = {
    Name = "${var.project_name}-sqs-${each.value}-dlq"
  }
}

# Main FIFO Queues
resource "aws_sqs_queue" "fifo" {
  for_each                    = toset(var.queue_names)
  name                        = "${var.project_name}-sqs-${each.value}.fifo"
  fifo_queue                  = true
  content_based_deduplication = true

  redrive_policy = contains(var.dlq_queue_names, each.value) ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.value].arn
    maxReceiveCount     = var.max_receive_count
  }) : null

  tags = {
    Name = "${var.project_name}-sqs-${each.value}"
  }
}