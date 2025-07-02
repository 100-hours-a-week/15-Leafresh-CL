# 1) Network Load Balancer 생성
resource "aws_lb" "this" {
  name                       = "${var.project_name}-nlb"
  load_balancer_type         = "network"
  subnets                    = var.subnet_ids
  enable_deletion_protection = false
}

# 2) Target Group (TCP 80)
resource "aws_lb_target_group" "be" {
  name        = "${var.project_name}-nlb-tg-be"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "TCP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 10
    timeout             = 5
  }
}

# 3) Listener (TCP:80 → BE TG)
resource "aws_lb_listener" "tcp_80" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.be.arn
  }
}

# 4) 인스턴스 등록 (for_each 로 여러 인스턴스도 지원)
resource "aws_lb_target_group_attachment" "be_attach" {
  count             = length(var.instance_ids)        # plan 시점에 알 수 있는 개수
  target_group_arn  = aws_lb_target_group.be.arn
  target_id         = var.instance_ids[count.index]   # apply 시점에 결정된 ID
  port              = 80
}
