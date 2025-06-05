# modules/pubsub/main.tf

resource "google_pubsub_topic" "be" {
  for_each = var.pubsub_topic_names

  name    = each.key
  project = var.project_id_dev

  labels = {
    role        = "topic"
    purpose     = "event-stream"
    environment = "dev"
    app         = "leafresh"
  }
}

resource "google_pubsub_subscription" "be" {
  for_each = var.pubsub_topic_names

  name  = each.value.subscription_name
  topic = google_pubsub_topic.be[each.key].id
  project = var.project_id_dev

  ack_deadline_seconds = 20

  labels = {
    role        = "subscription"
    purpose     = "event-consumer"
    environment = "dev"
    app         = "leafresh"
  }

  depends_on = [
    google_pubsub_topic.be
  ]
}
