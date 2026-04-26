resource "aws_instance" "mongodb" {
    ami = data.aws_ami.ami_data.id

    instance_type = "t3.micro"
    vpc_security_group_ids = [local.mongodb_sg_id]
    subnet_id = local.subnet_id
      tags = merge(
    
    local.common_tags,
    {
        Name = "${local.common_suffix}-mongodb" # roboshop-dev-catalogue
    }
  )
}

resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id   # triggers when mongodb instance id changes 
    
  ]
  connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.mongodb.private_ip   # connecting using private possible via bastion 
    }

 # terraform copies this file to mongodb server
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",  # execute access 
        "sudo sh /tmp/bootstrap.sh mongodb"    # runs booststrap.sh    
    ]
  }
  
}



resource "aws_instance" "redis" {
    ami = data.aws_ami.ami_data.id

    instance_type = "t3.micro"
    vpc_security_group_ids = [local.redis_sg_id]
    subnet_id = local.subnet_id
      tags = merge(
    
    local.common_tags,
    {
        Name = "${local.common_suffix}-redis" # roboshop-dev-catalogue
    }
  )
}

resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id   # triggers when mongodb instance id changes 
    
  ]
  connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.redis.private_ip   # connecting using private possible via bastion 
    }

 # terraform copies this file to mongodb server
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",  # execute access 
        "sudo sh /tmp/bootstrap.sh redis"    # runs booststrap.sh    
    ]
  }
  
}


# rabbitmq

resource "aws_instance" "rabbitmq" {
    ami = data.aws_ami.ami_data.id

    instance_type = "t3.micro"
    vpc_security_group_ids = [local.rabbitmq_sg_id]
    subnet_id = local.subnet_id
      tags = merge(
    
    local.common_tags,
    {
        Name = "${local.common_suffix}-rabbitmq" # roboshop-dev-catalogue
    }
  )
}


resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id   # triggers when mongodb instance id changes 
    
  ]
  connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.rabbitmq.private_ip  # connecting using private possible via bastion 
    }

 # terraform copies this file to mongodb server
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",  # execute access 
        "sudo sh /tmp/bootstrap.sh rabbitmq"    # runs booststrap.sh    
    ]
  }
  
}

# First terraform apply →
# EC2 instance is created → then terraform_data runs
# → copies bootstrap.sh → executes it on the instance
# If EC2 is recreated (new ID) →
# triggers_replace detects change → terraform_data runs again


# mysql

resource "aws_instance" "mysql" {
    ami = data.aws_ami.ami_data.id

    instance_type = "t3.micro"
    vpc_security_group_ids = [local.mysql_sg_id]
    subnet_id = local.subnet_id
    iam_instance_profile = aws_iam_instance_profile.mysql.name
      tags = merge(
    
    local.common_tags,
    {
        Name = "${local.common_suffix}-mysql" # roboshop-dev-catalogue
    }
  )
}

<<<<<<< HEAD
# “Trigger runs the first time when the ID is created, and again whenever the ID changes (like when the instance is recreated).”
# terraform_data = container to run provisioners
# triggers_replace = condition that forces it to run again
=======
resource "aws_iam_instance_profile" "mysql" {
  name = "mysql"
  role = "EC2SSMParameterRead"
}
>>>>>>> a25872e (local changes from PC)

resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id   # triggers when mongodb instance id changes 
    
  ]
  connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.mysql.private_ip  # connecting using private possible via bastion 
    }

 # terraform copies this file to mongodb server
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",  # execute access 
        "sudo sh /tmp/bootstrap.sh mysql dev"    # runs booststrap.sh    
    ]
  }
  
}
