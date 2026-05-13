resource "aws_instance" "catalogue" {
    ami = data.aws_ami.ami_data.id

    instance_type = "t3.micro"
    vpc_security_group_ids = [local.catalogue_sg_id]
    subnet_id = local.private_subnet_id
      tags = merge(
    
    local.common_tags,
    {
        Name = "${local.common_suffix}-catalogue" # roboshop-dev-catalogue
    }
  )
}

# connect to instance using remote exec provisioner through terraform_data
resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id   # triggers when mongodb instance id changes 
    
  ]
  connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.catalogue.private_ip  # connecting using private possible via bastion 
    }

#  source = "catalogue.sh"
# → File on your local system (where Terraform is running)
# destination = "/tmp/catalogue.sh"
# → Path on the remote server (EC2)

  provisioner "file" {
    source = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/catalogue.sh",  # execute access 
        "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"    # runs catalogue.sh    
    ]
  }
  
}

# stop the instance to take image 
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state = "stopped"
  depends_on = [ terraform_data.catalogue]
}

resource "aws_ami_from_instance" "catalogue" {
  name = "${local.common_suffix}-catalogue-ami"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [ aws_ami_from_instance.catalogue ]
}
 
resource "aws_lb_target_group" "catalogue" {
  name     = "${local.common_suffix}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  deregistration_delay = 60 # waiting period before deleting the instance 
  #before lb sending traffic to the instance  lb will do health checkup 
  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/health" 
    port = 8080
    protocol = "HTTP"
    timeout = 2
    unhealthy_threshold = 2   
  }
}

resource "aws_launch_template" "catalogue" {
  name = "${local.common_suffix}-catalogue"
  image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  # when we run terraform apply again, a new version will be created with new AMI ID
  # no need to create aws_launch template again here 
  update_default_version = true
  # tags attached to the instances   
  tag_specifications {
    resource_type = "instance"
    tags = merge( 
    local.common_tags,
    {
        Name = "${local.common_suffix}-catalogue" # roboshop-dev-catalogue
    }
  )
  }

 # tags attached to the volume created by instance 
 tag_specifications {
    resource_type = "volume"
    tags = merge( 
    local.common_tags,
    {
        Name = "${local.common_suffix}-catalogue" # roboshop-dev-catalogue
    }
  )
  }

 #tags attached to the launch template 
 tags = merge( 
    local.common_tags,
    {
        Name = "${local.common_suffix}-catalogue" # roboshop-dev-catalogue
    }
  )
 }


resource "aws_autoscaling_group" "catalogue" {
  name                      = "${local.common_suffix}-catalogue"
  max_size                  = 10
  min_size                  = 1
  #after 100 secs health check should be done
  health_check_grace_period = 100
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
   launch_template {
    id      = aws_launch_template.catalogue.id
    # ASG with referesh with latest version of launch template 
    version = aws_launch_template.catalogue.latest_version
  }
  vpc_zone_identifier       = local.private_subnet_ids
  target_group_arns = [aws_lb_target_group.catalogue.arn]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50 # atleast 50% of the instances should be up and running
    }
    triggers = ["launch_template"]   # when launch template changes it triggers 
  }
 
  dynamic "tag" {  # we will get the iterator with name as tag
    for_each = merge(
      local.common_tags,
      {
        Name = "${local.common_suffix}-catalogue"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  name                   = "${llocal.common_suffix}-catalogue"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

# adding rule to backend ALB

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listener_arn
  priority     = 10

   condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}.${var.domain_name}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }
}

resource "terraform_data" "catalogue_local" {
  triggers_replace = [
    aws_instance.catalogue.id
  ]
  
  depends_on = [aws_autoscaling_policy.catalogue]
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }
}