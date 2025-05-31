resource "aws_ses_domain_identity" "ses_domain" {
  domain = aws_route53_zone.twindb_com.name
}

resource "aws_route53_record" "amazonses_verification_record" {
  zone_id = aws_route53_zone.twindb_com.zone_id
  name    = "_amazonses.${aws_route53_zone.twindb_com.name}"
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

resource "aws_iam_user" "emailer" {
  name = "${var.environment}-emailer"
}

resource "aws_iam_access_key" "emailer" {
  user = aws_iam_user.emailer.name
}

data "aws_iam_policy_document" "emailer-permissions" {
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]
    resources = [
      aws_ses_domain_identity.ses_domain.arn,
      module.infrahouse_com.ses_domain_arn,
    ]
  }
}

resource "aws_iam_policy" "emailer" {
  name   = "${var.environment}-emailer"
  policy = data.aws_iam_policy_document.emailer-permissions.json
}

resource "aws_iam_user_policy_attachment" "emailer" {
  user       = aws_iam_user.emailer.name
  policy_arn = aws_iam_policy.emailer.arn
}

module "smtp_credentials" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.0.1"
  secret_description = "SMTP credentials for Postfix smarthost"
  secret_name_prefix = "smtp_credentials"
  environment        = var.environment
  secret_value = jsonencode(
    {
      user : aws_iam_access_key.emailer.id,
      password : aws_iam_access_key.emailer.ses_smtp_password_v4
    }
  )
  readers = [
    module.jumphost.jumphost_role_arn,
    module.mail_twindb_com.instance_role_arn,
    module.terraform-aws-github-backup.instance_role_arn,
  ]
}
