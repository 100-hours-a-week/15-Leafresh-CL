resource "google_dns_record_set" "this" {
  for_each = {
    for dvo in var.domain_validation_options :
    dvo.domain_name => dvo
  }
  name         = each.value.resource_record_name
  type         = each.value.resource_record_type
  ttl          = 300
  managed_zone = var.zone_name
  rrdatas      = [each.value.resource_record_value]
}
