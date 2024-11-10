resource "aws_route53_zone" "infrahouse_com" {
  name = "infrahouse.com"
}

## MX
resource "aws_route53_record" "mx" {
  name    = aws_route53_zone.infrahouse_com.name
  type    = "MX"
  zone_id = aws_route53_zone.infrahouse_com.id
  ttl     = 3600
  records = [
    "1 aspmx.l.google.com.",
    "5 alt1.aspmx.l.google.com.",
    "5 alt2.aspmx.l.google.com.",
    "10 alt3.aspmx.l.google.com.",
    "10 alt4.aspmx.l.google.com."
  ]
}

resource "aws_route53_record" "txt_spf" {
  name    = aws_route53_zone.infrahouse_com.name
  type    = "TXT"
  zone_id = aws_route53_zone.infrahouse_com.id
  records = [
    "v=spf1 include:_spf.google.com -all",
    "google-site-verification=ytNdHWPzw0hCDu7xIF1fWtocIKbwppJoo9Pe1xoo3VE",
  ]
  ttl = 3600
}

resource "aws_route53_record" "txt_dkim" {
  name    = "google._domainkey.${aws_route53_zone.infrahouse_com.name}"
  type    = "TXT"
  zone_id = aws_route53_zone.infrahouse_com.id
  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAhRsHTvHGTZIg60W5xybWjEAa3dbxh1qUxM5yS4LAEOtPm6dlNO88SMbXQP+h82kffiOukmWnEgzoUmDs8yEqn9AuMpEsVLH5tLbzpQhWOAzEJ5aLQKtgb5snES2gdkb2jeZX60dhBm9CzlZHhBiSZRp1+hWu02f9aLe2WYwFsL/lsQsTwzYN8mTc83l/UQ2e/\"\"adsylAdWJlPmd9p8VIr63aMLVBmid2AWDQnj1RgKOHNARz6d3meTg602EEiI0+0OzHd8Zdc16kY3NUYZ1u8GBuCA5hleAYtefshhmwn5pSg375urhl3+480vp0H/jyq+DGYrDZ5Cqwgd2HjSCrzFwIDAQAB"
  ]
  ttl = 3600
}

resource "aws_route53_record" "_gh-infrahouse-o" {
  name    = "_gh-infrahouse-o.${aws_route53_zone.infrahouse_com.name}"
  type    = "TXT"
  zone_id = aws_route53_zone.infrahouse_com.id
  records = [
    "4e1245e5cc"
  ]
  ttl = 3600
}

