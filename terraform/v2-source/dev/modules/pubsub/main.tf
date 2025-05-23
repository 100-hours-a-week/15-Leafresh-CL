# modules/pubsub/main.tf

resource "google_project_iam_member" "pubsub_iam_enable" {
  project = var.project_id
  role    = "roles/editor" # 필요한 최소 권한으로 변경
  member  = "serviceAccount:${var.project_number}@cloudservices.gserviceaccount.com" # Pub/Sub 서비스 계정
}

resource "google_pubsub_topic" "gpu_instance_topic" {
  project = var.project_id
  name    = "leafresh-pubsub"
}
