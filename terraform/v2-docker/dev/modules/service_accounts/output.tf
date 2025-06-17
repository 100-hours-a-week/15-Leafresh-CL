output "bindings" {
  value = [
    for sa in var.service_accounts : {
      member = "serviceAccount:${google_service_account.this[sa.account_id].email}"
      roles  = sa.roles
    }
  ]
}
