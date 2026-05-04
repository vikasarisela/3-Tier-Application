resource "aws_lb" "backend_lb" {
  name               = "${local.common_suffix}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = local.private_subnet_ids

  enable_deletion_protection = true

   tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "backend_alb" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hi, i am from backend http"
      status_code  = "200"
    }
  }
}

# rule written in listener if user hits catalogue.backend-alb-dev-cloudksills.fun then request should go to catalogue target group

# Terraform code makes all subdomains automatically point to your load balancer without using IP addresses
resource "aws_route53_record" "backend_alb" {
  zone_id = data.aws_route53_zone.cloudskills.zone_id
  name    = "*.backend-alb-${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.backend_lb.dns_name
    zone_id                = aws_lb.backend_lb.zone_ids
    evaluate_target_health = true
  }
}

# When users type mywebsite.com
# DNS automatically points to myapp-123456.elb.amazonaws.com


