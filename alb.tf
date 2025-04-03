resource "aws_alb" "hcl_main" {
  name            = "hcl-load-balancer"
  load_balancer_type = "application"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.hcl_lb.id]
}

resource "aws_alb_target_group" "hcl_appointment_app" {
  name        = "appointment-target-group"
  port        = local.appointment_container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

##TODO include WAF in front of the loadbalancer with cloudfront

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "appointment_listener" {
  load_balancer_arn = aws_alb.hcl_main.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.hcl_appointment_app.arn
    type             = "forward"
  }
}

resource "aws_alb_target_group" "hcl_patient_app" {
  name        = "patient-target-group"
  port        = local.patient_container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "patient_listener" {
  load_balancer_arn = aws_alb.hcl_main.id
  port              = local.patient_container_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.hcl_patient_app.arn
    type             = "forward"
  }
}