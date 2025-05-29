output "iam_roles" {
  description = "프로젝트에 반영하는 권한"
  value       = [for b in var.iam_bindings : b.role]
}

output "iam_members" {
  description = "권한 부여하는 멤버들"
  value       = [for b in var.iam_bindings : b.member]
}

