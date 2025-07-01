resource "aws_lb" "this" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = var.security_group_ids

  tags = { Name = "${var.project_name}-alb" }
}

resource "aws_lb_target_group" "fe" {
  name     = "${var.project_name}-tg-fe"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = { Name = "${var.project_name}-tg" }
}

resource "aws_lb_target_group" "monitoring" {
  name     = "${var.project_name}-tg-monitoring"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/monitoring"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_target_group" "argocd" {
  name     = "${var.project_name}-tg-argo"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/argocd"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fe.arn
  }
}

resource "aws_lb_listener_rule" "monitoring_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 200
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.monitoring.arn
  }
  condition {
    path_pattern {
      values = ["/monitoring*", "/prometheus*"]
    }
  }
}

resource "aws_lb_listener_rule" "argocd_rule" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 300
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.argocd.arn
  }
  condition {
    path_pattern {
      values = ["/argocd*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "fe_attach" {
  target_group_arn = aws_lb_target_group.fe.arn
  target_id        = var.instance_id_k8s_worker_fe
  port             = 80
}
resource "aws_lb_target_group_attachment" "mon_attach" {
  target_group_arn = aws_lb_target_group.monitoring.arn
  target_id        = var.instance_id_monitoring
  port             = 80
}
resource "aws_lb_target_group_attachment" "argo_attach" {
  target_group_arn = aws_lb_target_group.argocd.arn
  target_id        = var.instance_id_argocd
  port             = 80
}