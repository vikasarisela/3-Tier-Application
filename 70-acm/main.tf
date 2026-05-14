resource "aws_acm_certificate" "Three-Tier-Application" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"

  tags = merge(
    
    local.common_tags,
    {
        Name =  local.common_suffix
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "Three-Tier-Application" {
  for_each = {
    for dvo in aws_acm_certificate.Three-Tier-Application : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 1 
  type            = each.value.type
  zone_id         = local.zone_id
}

resource "aws_acm_certificate_validation" "Three-Tier-Application" {
  certificate_arn         = aws_acm_certificate.Three-Tier-Application.arn
  validation_record_fqdns = [for record in aws_route53_record.Three-Tier-Application : record.fqdn]
}