locals {

    common_tags = {
    Terraform = "true"
    Project = "3-Tier-App"
    Environment = "dev"
  }
   common_suffix = "${var.project_name}-${var.environment}"
  ami_id = data.aws_ami.ami_data.id
 
  public_subnet_id = split("," , data.aws_ssm_parameter.public_subnet_ids.value)[0]
    openvpn_sg_id = data.aws_ssm_parameter.openvpn_sg_id.value
  zone_id = data.aws_route53_zone.cloudskills.zone_id.value
}