locals {
  name_prefix = substr("teleport", 0, 6)
}

resource "aws_alb" "teleport" {
  name_prefix                = local.name_prefix
  enable_deletion_protection = false
  subnets                    = var.frontend_subnet_ids
  idle_timeout               = 300
  internal                   = !data.aws_subnet.frontend.map_public_ip_on_launch
  security_groups = [
    aws_security_group.external.id,
    aws_security_group.backend.id,
  ]
  tags = merge(
    local.default_module_tags,
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}

resource "aws_alb_listener" "redirect_to_ssl" {
  load_balancer_arn = aws_alb.teleport.arn
  port              = 80
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  tags = merge(
    local.default_module_tags,
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}

resource "aws_lb_listener" "ssl" {
  load_balancer_arn = aws_alb.teleport.arn
  port              = 443
  protocol          = "HTTPS"
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/describe-ssl-policies.html
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Ext1-2021-06"
  certificate_arn = aws_acm_certificate.teleport.arn
  default_action {
    type = "fixed-response"
    fixed_response {
      status_code  = "400"
      content_type = "text/plain"
      message_body = "The server cannot or will not process the request due to an apparent client error (e.g., malformed request syntax, size too large, invalid request message framing, or deceptive request routing)."
    }
  }
  depends_on = [
    aws_acm_certificate_validation.teleport
  ]
  tags = merge(
    local.default_module_tags,
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}

resource "aws_alb_listener_rule" "teleport" {
  listener_arn = aws_lb_listener.ssl.arn
  priority     = 99
  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.teleport.arn
  }
  condition {
    host_header {
      values = [
        "teleport.${data.aws_route53_zone.selected.name}"
      ]
    }
  }
  tags = merge(
    local.default_module_tags,
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )
}

resource "aws_alb_target_group" "teleport" {
  port        = 3080
  protocol    = "HTTPS"
  target_type = "instance"
  vpc_id      = data.aws_subnet.backend.vpc_id
  stickiness {
    type    = "lb_cookie"
    enabled = true
  }

  health_check {
    enabled  = true
    path     = "/web"
    port     = 3080
    protocol = "HTTPS"
    # healthy_threshold   = var.alb_healthcheck_healthy_threshold
    # unhealthy_threshold = var.alb_healthcheck_uhealthy_threshold
    # interval            = var.alb_healthcheck_interval
    # timeout             = var.alb_healthcheck_timeout
    # matcher             = var.alb_healthcheck_response_code_matcher
  }
  tags = merge(
    local.default_module_tags,
    {
      VantaContainsUserData : false
      VantaContainsEPHI : false
    }
  )

}
