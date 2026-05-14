locals {
  common_tags = {
    Terraform = "true"
    Project = "3-Tier-App"
    Environment = "dev"
  }
   common_suffix = "${var.project_name}-${var.environment}"
   frontend_alb_sg_id = data.aws_ssm_parameter.frontend_alb_sg_id.value
   public_subnet_ids =  split("," , data.aws_ssm_parameter.public_subnet_ids.value)

}