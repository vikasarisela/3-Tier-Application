data "aws_ami" "ami_data" {
    owners           = ["973714476881"]   
    most_recent      = true
    # ami providers owner account id 
    # owner ID is static, AMIs are not static
    filter {
        name   = "name"
        values = ["OpenVPN Access Server Community Image-8fbe3379-*"]
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


data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "openvpn_sg_id" {
  name = "/${var.project_name}/${var.environment}/open_vpn_sg_id"
}

data "aws_route53_zone" "cloudskills" {
  name         = "cloudskills.fun"
  private_zone = false
}

output "zone_id" {
 value =  data.aws_route53_zone.cloudskills.zone_id
}