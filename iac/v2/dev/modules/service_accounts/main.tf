resource "google_service_account" "this" {
  for_each = { for sa in var.service_accounts : sa.account_id => sa }

  project      = var.project_id
  account_id   = each.value.account_id
  display_name = each.value.display_name
}

