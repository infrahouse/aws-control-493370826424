resource "aws_route53_record" "ci-cd-ns" {
  provider = aws.aws-493370826424-uw1
  name     = data.aws_route53_zone.cicd-ih-com.name
  type     = "NS"
  zone_id  = module.infrahouse_com.infrahouse_zone_id
  ttl      = 172800
  records  = data.aws_route53_zone.cicd-ih-com.name_servers
}
