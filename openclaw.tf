data "aws_iam_policy_document" "openclaw_ses" {
  statement {
    sid    = "SESSend"
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = [
      module.infrahouse_com.ses_domain_arn,
    ]
  }
}
