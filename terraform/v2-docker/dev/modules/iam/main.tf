locals {
  iam_bindings = flatten([
    [
      for b in var.service_account_bindings : [
        for role in b.roles : {
          member = b.member
          role   = role
        }
      ]
    ],
    [
      for u in var.user_accounts : [
        for role in u.roles : {
          member = u.member
          role   = role
        }
      ]
    ],
  ])

  # 고유 key 생성 (special char 제거)
  binding_map_project = {
    for b in local.iam_bindings :
    "${replace(replace(b.member, "[:@\\./]", "-"), "--", "-")}-${replace(b.role, "/", "-")}" => b
  }
}

locals {
  flat = flatten([
    for bucket_key, bindings in var.iam_storage_bindings_per_bucket : [
      for bind in bindings : {
        id          = "${bucket_key}-${bind.role}"
        bucket_name = var.gcs_bucket_names[bucket_key]
        role        = bind.role
        members     = bind.members
      }
    ]
  ])

  binding_map_bucket = {
    for obj in local.flat :
    obj.id => obj
  }
}




resource "google_project_iam_member" "this" {
  for_each = local.binding_map_project

  project = var.project_id_dev
  member  = each.value.member
  role    = each.value.role
}

resource "google_storage_bucket_iam_binding" "this" {
  for_each = local.binding_map_bucket

  bucket  = each.value.bucket_name
  role    = each.value.role
  members = each.value.members
}

