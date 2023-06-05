resource "aws_acm_certificate" "ecs-domain-certificate" {
  domain_name       = "*.${var.ecs_domain_name}"
  validation_method = "DNS"
  tags = {
    Name = "${var.ecs-cluster-name}-certificate"
  }
}

data "aws_route53_zone" "ecs_domain" {
  name         = var.ecs_domain_name
  private_zone = false
}

resource "aws_route53_record" "ecs_cert_vald_rec" {
  for_each = {
    for dvo in aws_acm_certificate.ecs-domain-certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.ecs_domain.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id

}


resource "aws_acm_certificate_validation" "ecs_domain_cert_vals" {
  certificate_arn         = aws_acm_certificate.ecs-domain-certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.ecs_cert_vald_rec : record.fqdn]
}

