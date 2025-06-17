#output "iam_roles_project" {
#  description = "프로젝트에 반영하는 권한"
#  value       = [for b in var.iam_project_bindings : b.role]
#}
#
#output "iam_members_project" {
#  description = "권한 부여하는 멤버들"
#  value       = [for b in var.iam_project_bindings : b.members]
#}

output "iam_roles_storage" {
  description = "프로젝트에 반영하는 스토리지 버킷 IAM 권한 역할 목록"
  value = flatten([
    for bucket_key, bindings_list in var.iam_storage_bindings_per_bucket : # Iterate through the map values (lists of bindings)
    [
      for binding in bindings_list : # Iterate through each binding object in the list
      binding.role                   # Access the 'role' attribute of the binding object
    ]
  ])
}

output "iam_members_storage" {
  description = "스토리지 버킷 IAM 권한을 부여받는 멤버 목록"
  value = flatten([
    for bucket_key, bindings_list in var.iam_storage_bindings_per_bucket : # Iterate through the map values (lists of bindings)
    [
      for binding in bindings_list : # Iterate through each binding object in the list
      binding.members                # Access the 'members' attribute (which is a list itself)
    ]
  ])
}

# (Optional) If you want a flat list of all individual members, you'd flatten twice:
output "iam_individual_members_storage" {
  description = "스토리지 버킷 IAM 권한을 부여받는 개별 멤버들의 평탄화된 목록"
  value = flatten([
    for bucket_key, bindings_list in var.iam_storage_bindings_per_bucket :
    [
      for binding in bindings_list :
      binding.members # This gives you [[member1, member2], [member3]]
    ]
  ])
}
