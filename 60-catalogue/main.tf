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
        "sudo sh /tmp/catalogue.sh catalogue"    # runs catalogue.sh    
    ]
  }
  
}

