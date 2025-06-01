resource "google_project_iam_binding" "bindings" {
  for_each = { for idx, binding in var.iam_project_bindings : idx => binding }

  project = var.project_id_dev
  role    = each.value.role
  members = [each.value.member]
}

resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = { for idx, binding in var.iam_storage_bindings : idx => binding }

  bucket  = var.storage_name
  role    = each.value.role
  members = [each.value.member]
}