# modules/pubsub/main.tf

resource "google_pubsub_topic" "be_topic" {
  project = var.project_id_dev
  name    = var.pubsub_topic_name
}

resource "google_pubsub_subscription" "be_subscription" {
  name                 = var.pubsub_subscription_name
  project              = var.project_id_dev
  topic                = "projects/${var.project_id_dev}/topics/${google_pubsub_topic.be_topic.name}"
  ack_deadline_seconds = 20

  depends_on = [
    google_pubsub_topic.be_topic
  ]
}

