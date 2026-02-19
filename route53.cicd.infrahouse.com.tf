resource "aws_route53_record" "ci-cd-ns" {
  provider = aws.aws-493370826424-uw1
  name     = "ci-cd.infrahouse.com"
  type     = "NS"
  zone_id  = module.infrahouse_com.infrahouse_zone_id
  ttl      = 172800
  records = [
    "ns-1311.awsdns-35.org",
    "ns-1795.awsdns-32.co.uk",
    "ns-261.awsdns-32.com",
    "ns-776.awsdns-33.net",
  ]
}
