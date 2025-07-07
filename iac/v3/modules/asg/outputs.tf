output "asg_names" {
    value = {
    for key, inst in aws_autoscaling_group.this :
    key => inst.name
  }
}

output "asg_arns" {
  value = {
    for key, inst in aws_autoscaling_group.this :
    key => inst.arn
  }
}