output "fqdns" {
  value = [for rec in google_dns_record_set.this : rec.name]
}