resource "aws_ses_domain_identity" "ses_domain" {
  domain = aws_route53_zone.infrahouse_com.name
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = aws_route53_zone.infrahouse_com.zone_id
  name    = "_amazonses.${aws_route53_zone.infrahouse_com.name}"
  type    = "TXT"
  ttl     = "600"
  records = [
    aws_ses_domain_identity.ses_domain.verification_token
  ]
}

resource "aws_ses_domain_identity_verification" "verification" {
  domain = aws_ses_domain_identity.ses_domain.domain
  depends_on = [
    aws_route53_record.amazonses_verification_record
  ]
}

## DKIM
resource "aws_ses_domain_dkim" "infrahouse" {
  domain = aws_ses_domain_identity.ses_domain.domain
}

resource "aws_route53_record" "ses_dkim" {
  count   = 3
  zone_id = aws_route53_zone.infrahouse_com.zone_id
  name = join(".", [
    aws_ses_domain_dkim.infrahouse.dkim_tokens[count.index],
    "_domainkey",
    aws_route53_zone.infrahouse_com.name
  ])
  type = "CNAME"
  ttl  = 600
  records = [
    "${aws_ses_domain_dkim.infrahouse.dkim_tokens[count.index]}.dkim.amazonses.com"
  ]
}

## MAIL FROM
resource "aws_ses_domain_mail_from" "infrahouse" {
  domain           = aws_ses_domain_identity.ses_domain.domain
  mail_from_domain = "mail.${aws_route53_zone.infrahouse_com.name}"
}

resource "aws_route53_record" "ses_mail_from_mx" {
  zone_id = aws_route53_zone.infrahouse_com.zone_id
  name    = "mail.${aws_route53_zone.infrahouse_com.name}"
  type    = "MX"
  ttl     = 600
  records = [
    "10 feedback-smtp.us-west-1.amazonses.com"
  ]
}

resource "aws_route53_record" "ses_mail_from_spf" {
  zone_id = aws_route53_zone.infrahouse_com.zone_id
  name    = "mail.${aws_route53_zone.infrahouse_com.name}"
  type    = "TXT"
  ttl     = 600
  records = [
    "v=spf1 include:amazonses.com -all"
  ]
}
