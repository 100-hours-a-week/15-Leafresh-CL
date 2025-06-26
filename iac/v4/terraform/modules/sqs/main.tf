# modules/sqs/main.tf

locals {
  # 큐 이름을 조합하기 위한 locals
  order_queue_name      = "${var.project_name}-order-queue"
  order_dlq_name        = "${var.project_name}-order-dlq-queue"
  send_to_ai_queue_name = "${var.project_name}-send-to-ai-queue"
  send_to_be_queue_name = "${var.project_name}-send-to-be-queue"

  # 일반적인 SQS 큐 태그
  common_tags = merge({
    Project     = var.project_name
    Environment = var.environment
  }, var.additional_tags)
}

# 1. 주문 처리를 위한 SQS 메인 큐
resource "aws_sqs_queue" "order_queue" {
  name                       = local.order_queue_name
  delay_seconds              = var.order_queue_delay_seconds
  max_message_size           = var.order_queue_max_message_size
  message_retention_seconds  = var.order_queue_message_retention_seconds
  receive_wait_time_seconds  = var.order_queue_receive_wait_time_seconds
  visibility_timeout_seconds = var.order_queue_visibility_timeout_seconds

  # Dead Letter Queue (DLQ) 설정: order_dlq_queue와 연결
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.order_dlq_queue.arn
    maxReceiveCount     = var.order_queue_max_receive_count # DLQ로 보내기 전 재시도 횟수
  })

  tags = merge(local.common_tags, {
    Name    = local.order_queue_name
    Purpose = "Order Processing Main"
  })
}

# 2. 주문 처리를 위한 SQS Dead-Letter Queue (DLQ)
resource "aws_sqs_queue" "order_dlq_queue" {
  name                      = local.order_dlq_name
  message_retention_seconds = var.order_dlq_message_retention_seconds # DLQ 메시지 보존 기간

  tags = merge(local.common_tags, {
    Name    = local.order_dlq_name
    Purpose = "Order Processing DLQ"
  })
}

# 3. AI 서비스로 메시지 발송을 위한 SQS 큐
resource "aws_sqs_queue" "send_to_ai_queue" {
  name                       = local.send_to_ai_queue_name
  delay_seconds              = var.send_to_ai_queue_delay_seconds
  max_message_size           = var.send_to_ai_queue_max_message_size
  message_retention_seconds  = var.send_to_ai_queue_message_retention_seconds
  receive_wait_time_seconds  = var.send_to_ai_queue_receive_wait_time_seconds
  visibility_timeout_seconds = var.send_to_ai_queue_visibility_timeout_seconds

  tags = merge(local.common_tags, {
    Name    = local.send_to_ai_queue_name
    Purpose = "Send to AI Service"
  })
}

# 4. 백엔드 서비스로 메시지 발송을 위한 SQS 큐
resource "aws_sqs_queue" "send_to_be_queue" {
  name                       = local.send_to_be_queue_name
  delay_seconds              = var.send_to_be_queue_delay_seconds
  max_message_size           = var.send_to_be_queue_max_message_size
  message_retention_seconds  = var.send_to_be_queue_message_retention_seconds
  receive_wait_time_seconds  = var.send_to_be_queue_receive_wait_time_seconds
  visibility_timeout_seconds = var.send_to_be_queue_visibility_timeout_seconds

  tags = merge(local.common_tags, {
    Name    = local.send_to_be_queue_name
    Purpose = "Send to Backend Service"
  })
}
