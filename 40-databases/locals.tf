locals {
  common_tags = {
    Terraform = "true"
    Project = "3-Tier-App"
    Environment = "dev"
  }
   common_suffix = "${var.project_name}-${var.environment}"
  
   mongodb_sg_id = data.aws_ssm_parameter.mongodb_sg_id
   subnet_id = split("," , data.aws_ssm_parameter.private_subnet_ids.value)[0]

}