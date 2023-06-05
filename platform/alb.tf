resource "aws_alb" "ecs-cluster-alb" {
  name            = "${var.ecs-cluster-name}-alb"
  internal        = false
  security_groups = [aws_security_group.ecs-alb-sg.id]
  subnets         = var.public_subnet_ids
  tags = {
    Name = "${var.ecs-cluster-name}-alb"
  }
}

resource "aws_route53_record" "ecs-alb-record" {
  name    = "${var.prefix}.${var.ecs_domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.ecs_domain.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_alb.ecs-cluster-alb.dns_name
    zone_id                = aws_alb.ecs-cluster-alb.zone_id
  }
}

resource "aws_alb_target_group" "ecs-default-target-grp" {
  name     = "${var.ecs-cluster-name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  tags = {
    Name = "${var.ecs-cluster-name}-tg"
  }
}

resource "aws_alb_listener" "ecs-alb-https" {
  load_balancer_arn = aws_alb.ecs-cluster-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.ecs-domain-certificate.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-default-target-grp.arn
  }

  depends_on = [aws_alb_target_group.ecs-default-target-grp]
}

#====== ALB for ECS task Begin =======

resource "aws_alb_target_group" "ecs-app-target-group" {
  name        = "${var.ecs-cluster-name}-app-tg"
  port        = var.docker_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 60
    timeout             = 30
    unhealthy_threshold = "3"
    healthy_threshold   = "3"
  }

  tags = {
    Name = "${var.ecs-cluster-name}-app-tg"
  }
}


resource "aws_alb_listener_rule" "ecs-alb-listener-role" {
  listener_arn = aws_alb_listener.ecs-alb-https.arn
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs-app-target-group.arn
  }
  condition {
    host_header {
      values = ["${lower(var.ecs-cluster-name)}.${var.ecs_domain_name}"]
    }
  }
}