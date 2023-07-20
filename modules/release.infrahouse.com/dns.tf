resource "aws_route53_record" "release_infrahouse" {
  name    = local.domain_name
  type    = "A"
  zone_id = var.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.infrahouse-release.domain_name
    zone_id                = aws_cloudfront_distribution.infrahouse-release.hosted_zone_id
  }
}
