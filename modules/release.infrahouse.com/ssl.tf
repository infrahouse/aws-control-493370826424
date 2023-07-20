resource "aws_acm_certificate" "release_infrahouse" {
  provider          = aws.ue1
  domain_name       = local.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.release_infrahouse.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  name    = each.value.name
  type    = each.value.type
  zone_id = var.zone_id
  records = [
    each.value.record
  ]
  ttl = 60
}

resource "aws_acm_certificate_validation" "release_infrahouse" {
  provider        = aws.ue1
  certificate_arn = aws_acm_certificate.release_infrahouse.arn
  validation_record_fqdns = [
    aws_route53_record.cert_validation[aws_acm_certificate.release_infrahouse.domain_name].fqdn
  ]
}
