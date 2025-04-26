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

resource "aws_iam_user" "ha" {
  name = "home-assitant"
}

data "aws_iam_policy_document" "ha-permissions" {
  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = [aws_route53_zone.selfdrivedb_app.arn]
    condition {
      test     = "ForAllValues:StringEquals"
      values   = ["TXT"]
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
    }
  }
  statement {
    resources = ["*"]
    actions = [
      "route53:ListHostedZones"
    ]
  }
}

resource "aws_iam_policy" "ha-permissions" {
  name_prefix = "ha-permissions-"
  description = "Permissions for Home Assistant"
  policy      = data.aws_iam_policy_document.ha-permissions.json
}

resource "aws_iam_user_policy_attachment" "ha" {
  policy_arn = aws_iam_policy.ha-permissions.arn
  user       = aws_iam_user.ha.name
}

resource "aws_iam_access_key" "ha" {
  user = aws_iam_user.ha.name
}
