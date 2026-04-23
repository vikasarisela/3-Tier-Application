data "aws_ami" "ami_data" {
    owners           = ["973714476881"]   
    most_recent      = true
    # ami providers owner account id 
    # owner ID is static, AMIs are not static
    filter {
        name   = "name"
        values = ["Redhat-9-DevOps-Practice"]
    }

    filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}



output "amidata" {
  value = data.aws_ami.ami_data.id
}

# from 10-sg
data "aws_ssm_parameter" "bastion_sg_id" {
  name = "/${var.project_name}/${var.environment}/bastion_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}