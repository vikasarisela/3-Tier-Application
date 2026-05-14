data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "backend_alb_sg_id" {
   name  = "/${var.project_name}/${var.environment}/backend_alb_sg_id"
}


data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/private_subnet_ids"
}


# fetches zone id 
data "aws_route53_zone" "cloudskills" {
  name         = "cloudskills.fun"
  private_zone = false
}

output "zone_id" {
 value =  data.aws_route53_zone.cloudskills.zone_id
}