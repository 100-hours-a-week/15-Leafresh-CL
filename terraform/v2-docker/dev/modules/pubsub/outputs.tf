# modules/pubsub/outputs.tf

output "pubsub_topic_name" {
  description = "생성된 Pub/Sub Topic 이름"
  value       = google_pubsub_topic.gpu_instance_topic.name
}
