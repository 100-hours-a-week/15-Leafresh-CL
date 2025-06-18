resource "google_storage_bucket" "this" {
  for_each = var.buckets_config

  location                    = var.region
  project                     = var.project_id_dev
  name                        = each.value.name
  storage_class               = each.value.storage_class
  force_destroy               = each.value.force_destroy
  uniform_bucket_level_access = true

  dynamic "cors" {
    for_each = each.value.cors_config != null ? [each.value.cors_config] : []
    content {
      origin          = cors.value.origin
      method          = cors.value.method
      response_header = cors.value.response_header
      max_age_seconds = cors.value.max_age_seconds
    }
  }

  labels = merge({}, {
    env     = each.value.environment_label
    purpose = each.value.purpose_label
    }
  )
}
