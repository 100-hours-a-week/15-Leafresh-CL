# modules/pubsub/outputs.tf

output "pubsub_topic_name" {
  description = "생성된 Pub/Sub Topic 이름"
  value       = google_pubsub_topic.be_topic.name
}

output "pubsub_topic_subscription" {
  description = "생성된 Pub/Sub Subscription 이름"
  value       = google_pubsub_subscription.be_subscription.name
}