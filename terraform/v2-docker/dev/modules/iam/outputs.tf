output "iam_roles_project" {
  description = "프로젝트에 반영하는 권한"
  value       = [for b in var.iam_project_bindings : b.role]
}

output "iam_members_project" {
  description = "권한 부여하는 멤버들"
  value       = [for b in var.iam_project_bindings : b.member]
}

output "iam_roles_storage" {
  description = "프로젝트에 반영하는 권한"
  value       = [for b in var.iam_storage_bindings : b.role]
}

output "iam_members_storage" {
  description = "권한 부여하는 멤버들"
  value       = [for b in var.iam_storage_bindings : b.member]
}
