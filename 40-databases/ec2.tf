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

resource "terraform_data" "bootstrap" {
  triggers_replace = [
    aws_instance.mongodb.id   # triggers when mongodb instance id changes 
    
  ]
  connection {
      type     = "ssh"
      user     = "ec2-user"
      password = "DevOps321"
      host     = aws_instance.mongodb.private_ip
    }
  provisioner "remote-exec" {
    inline = [ "echo hello world.." ]
  }
}



