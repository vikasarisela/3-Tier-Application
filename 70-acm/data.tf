data "aws_route53_zone" "cloudskills" {
  name         = "cloudskills.fun"
  private_zone = false
}

output "zone_id" {
 value =  data.aws_route53_zone.cloudskills.zone_id
}