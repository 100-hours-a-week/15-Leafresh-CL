output "bucket_names" {
  description = "A map of the names of the created GCS buckets (key is the bucket config key)."
  value = {
    for key, bucket in google_storage_bucket.this : key => bucket.name
  }
}

output "bucket_ids" {
  description = "A map of the IDs of the created GCS buckets (key is the bucket config key)."
  value = {
    for key, bucket in google_storage_bucket.this : key => bucket.id
  }
}