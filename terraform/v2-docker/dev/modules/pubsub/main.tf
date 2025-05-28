# modules/pubsub/main.tf

resource "google_project_iam_member" "pubsub_iam_enable" {
  project = var.project_id
  role    = "roles/pubsub.editor" 
  member  = "serviceAccount:${var.project_number}@cloudservices.gserviceaccount.com" 
}

resource "google_pubsub_topic" "be_instance_topic" {
  project = var.project_id
  name    = "leafresh-pubsub-be"
}

resource "google_pubsub_subscription" "be_instance_subscription" {
  name  = "leafresh-pubsub-be-subscription"
  project = var.project_id
  # topic = google_pubsub_topic.be_instance_topic.name
  topic = "projects/${var.project_id}/topics/${google_pubsub_topic.be_instance_topic.name}"
  ack_deadline_seconds = 20
 
  depends_on = [
    google_pubsub_topic.be_instance_topic
  ]
}

