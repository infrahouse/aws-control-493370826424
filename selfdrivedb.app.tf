resource "aws_route53_zone" "selfdrivedb_app" {
  name = "selfdrivedb.app"
}

resource "aws_route53_record" "ha" {
  name    = "ha"
  type    = "A"
  zone_id = aws_route53_zone.selfdrivedb_app.id
  ttl     = 300
  records = [
    "192.168.1.219"
  ]
}
