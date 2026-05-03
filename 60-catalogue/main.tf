resource "aws_instance" "catalogue" {
    ami = data.aws_ami.ami_data.id

    instance_type = "t3.micro"
    vpc_security_group_ids = [local.catalogue_sg_id]
    subnet_id = local.subnet_id
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

  tag_specifications {
    resource_type = "instance"

    tags = merge( 
    local.common_tags,
    {
        Name = "${local.common_suffix}-catalogue" # roboshop-dev-catalogue
    }
  )
  }

  user_data = filebase64("${path.module}/example.sh")
  instance_id = aws_instance.catalogue.id
  state       = "stopped"
    depends_on = [terraform_data.catalogue]
}

# generating catalogue ami 
resource "aws_ami_from_instance" "catalogue" {
  name               = "${local.common_suffix}-catalogue-ami"
  source_instance_id = aws_ec2_instance_state.catalogue.id
  depends_on = [aws_ec2_instance_state.catalogue]

  tags = merge(
    
    local.common_tags,
    {
        Name = "${local.common_suffix}-catalogue-ami" # roboshop-dev-catalogue
    }
  )
}