locals {
  common_tags = {
    Terraform = "true"
    Project = "3-Tier-App"
    Environment = "dev"
  }
   common_suffix = "${var.project_name}-${var.environment}"
  
   mongodb_sg_id = data.aws_ssm_parameter.mongodb_sg_id.value
   redis_sg_id = data.aws_ssm_parameter.redis_sg_id.value
   rabbitmq_sg_id = data.aws_ssm_parameter.rabbitmq_sg_id.value
   mysql_sg_id = data.aws_ssm_parameter.mysql_sg_id.value


   subnet_id = split("," , data.aws_ssm_parameter.database_subnet_ids.value)[0]

}