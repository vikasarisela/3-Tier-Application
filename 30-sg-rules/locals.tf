locals {
  common_tags = {
    Terraform = "true"
    Project = "3-Tier-App"
    Environment = "dev"
  }
   common_suffix = "${var.project_name}-${var.environment}"
   backend_alb_sg_id = data.aws_ssm_parameter.backend_alb_sg_id.value
   bastion_sg_id = data.aws_ssm_parameter.bastion_sg_id.value
   mongodb_sg_id = data.aws_ssm_parameter.mongodb_sg_id.value

}