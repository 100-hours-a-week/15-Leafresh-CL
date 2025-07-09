resource "aws_autoscaling_group" "this" {
  for_each = var.launch_template_ids

  name_prefix          = "${var.project_name}-${each.key}-asg-"
  max_size             = var.max_size
  min_size             = var.min_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = var.subnet_ids

  launch_template {
    id      = each.value
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${each.key}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}