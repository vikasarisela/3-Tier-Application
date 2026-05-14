resource "aws_lb" "backend_lb" {
  name               = "${local.common_suffix}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = [local.public_subnet_ids]

  enable_deletion_protection = true

   tags = merge(
    
    local.common_tags,
    {
        Name = "${local.common_suffix}-frontend-alb" # roboshop-dev-catalogue
    }
  )
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-3-2021-06"
  certificate_arn   = data.aws_ssm_parameter.frontend_alb_certificate_arn

    default_action { 
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Hi, i am from https frontend alb"
      status_code  = "200"
    }
  }
}




# rule written in listener if user hits catalogue.backend-alb-dev-cloudksills.fun then request should go to catalogue target group

# Terraform code makes all subdomains automatically point to your load balancer without using IP addresses
resource "aws_route53_record" "frontend_alb" {
  zone_id = data.aws_route53_zone.cloudskills.zone_id
  name    = "three-tier-app-${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.frontend_lb.dns_name
    zone_id                = aws_lb.frontend_lb.zone_id
    evaluate_target_health = true
  }
}

# When users type mywebsite.com
# DNS automatically points to myapp-123456.elb.amazonaws.com
# Forward to ALB
# (using aws_lb.backend_lb.dns_name)
#            |
#            v
# ALB Listener receives request
#            |
#            v
# Listener rule checks:
# "Is hostname = catalogue.backend-alb-dev.example.com ?"
#            |
#            v
# YES
#            |
#            v
# Forward to Catalogue Target Group
#            |
#            v
# EC2/ECS running catalogue application

