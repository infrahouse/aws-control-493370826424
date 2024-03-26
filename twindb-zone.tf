resource "aws_route53_zone" "twindb_com" {
  name = "twindb.com"
}

resource "aws_route53_record" "mx_twindb_com" {
  name    = "twindb.com"
  type    = "MX"
  ttl     = 300
  zone_id = aws_route53_zone.twindb_com.zone_id
  records = [
    "10 mail.twindb.com"
  ]
}
