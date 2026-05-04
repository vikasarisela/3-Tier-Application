locals {
  common_tags = {
    Terraform = "true"
    Project = "3-Tier-App"
    Environment = "dev"
  }
   common_suffix = "${var.project_name}-${var.environment}"

   catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id.value
   private_subnet_id = split("," , data.aws_ssm_parameter.private_subnet_ids.value)[0]
   private_subnet_ids = split("," , data.aws_ssm_parameter.private_subnet_ids.value)
   backend_alb_listener_arn = data.aws_ssm_parameter.backend_alb_listener_arn.value


}