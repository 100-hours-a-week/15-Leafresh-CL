resource "google_project_iam_binding" "custom_bindings" {
  for_each = { for binding in var.iam_bindings : "${binding.role}_${binding.member}" => binding }

  project = var.project_id_dev
  role    = each.value.role
  members = [each.value.member]
}

