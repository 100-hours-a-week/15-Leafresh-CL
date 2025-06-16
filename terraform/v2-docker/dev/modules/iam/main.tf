resource "google_project_iam_binding" "this" {
  for_each = { for binding in var.iam_project_bindings : binding.role => binding }

  project = var.project_id_dev
  role    = each.value.role
  members = each.value.members
}

resource "google_storage_bucket_iam_binding" "this" {
  # `flatten`과 중첩된 `for` 표현식을 사용하여 모든 IAM 바인딩을 평탄화합니다.
  for_each = {
    for combined_key, binding_obj in flatten([
      for bucket_key, bindings_list in var.iam_storage_bindings_per_bucket :
      [
        for idx, binding in bindings_list : {
          # 고유한 키 생성: "bucket_key-role-idx" 또는 "bucket_key-idx"
          # role을 키에 포함하면 동일한 버킷/role에 대한 여러 binding이 발생할 때 혼란을 피할 수 있습니다.
          # 하지만 binding 자체는 role과 members를 포함하므로 idx만으로도 충분합니다.
          # 중요한 것은 이 키가 for_each 내에서 고유해야 한다는 것입니다.
          id          = "${bucket_key}-${binding.role}-${idx}" # 더 강력한 고유 키
          bucket_name = var.gcs_bucket_names[bucket_key]
          role        = binding.role
          members     = binding.members
        }
      ]
    ]) : combined_key => binding_obj
  }

  bucket  = each.value.bucket_name
  role    = each.value.role
  members = each.value.members
}