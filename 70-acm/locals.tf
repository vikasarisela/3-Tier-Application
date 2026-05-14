locals {
  common_tags = {
    Terraform = "true"
    Project = "3-Tier-App"
    Environment = "dev"
  }
   common_suffix = "${var.project_name}-${var.environment}"
   zone_id = data.aws_route53_zone.cloudskills.zone_id

}