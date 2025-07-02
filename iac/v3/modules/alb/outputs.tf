output "arn" {
  value = aws_lb.this.arn
}
output "dns_name" {
  value = aws_lb.this.dns_name
}
output "target_group_arn_fe" {
  value = aws_lb_target_group.fe.arn
}
output "target_group_arn_be" {
  value = aws_lb_target_group.be.arn
}
output "target_group_arn_monitoring" {
  value = aws_lb_target_group.monitoring.arn
}
output "target_group_arn_argocd" {
  value = aws_lb_target_group.argocd.arn
}
