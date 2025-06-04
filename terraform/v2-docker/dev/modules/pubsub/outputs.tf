# modules/pubsub/outputs.tf

# output "pubsub_topic_name" {
#   description = "생성된 Pub/Sub Topic 이름"
#   value       = google_pubsub_topic.be_topic.name
# }

# output "pubsub_topic_subscription" {
#   description = "생성된 Pub/Sub Subscription 이름"
#   value       = google_pubsub_subscription.be_subscription.name
# }

output "pubsub_topic_names" {
  description = "생성된 모든 Pub/Sub Topic 이름들"
  value       = {
    for topic_key, topic in google_pubsub_topic.be_topics :
    topic_key => topic.name
  }
}

output "pubsub_subscription_names" {
  description = "생성된 모든 Pub/Sub Subscription 이름들"
  value       = {
    for sub_key, sub in google_pubsub_subscription.be_subscriptions :
    sub_key => sub.name
  }
}