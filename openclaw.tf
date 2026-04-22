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

module "openclaw" {
  source  = "registry.infrahouse.com/infrahouse/openclaw/aws"
  version = "0.4.0"

  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.dns = aws.aws-493370826424-uw1
  }

  environment        = local.environment
  zone_id            = module.infrahouse_com.infrahouse_zone_id
  alb_subnet_ids     = module.management.subnet_public_ids
  backend_subnet_ids = module.management.subnet_private_ids

  alarm_emails   = local.alarm_emails
  cognito_users  = local.openclaw_users
  extra_packages = ["gh"]

  extra_instance_permissions = data.aws_iam_policy_document.openclaw_ses.json
  api_keys_writers = [
    local.admin_role_arn
  ]
  extra_bedrock_models = [
    {
      id   = "us.anthropic.claude-sonnet-4-6-v1:0"
      name = "Claude Sonnet 4.6"
    },
  ]
}
