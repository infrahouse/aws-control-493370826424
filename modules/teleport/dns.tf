resource "aws_route53_record" "teleport" {
  name    = "teleport.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  zone_id = var.zone_id
  ttl     = 300
  records = [
    aws_alb.teleport.dns_name
  ]
}
