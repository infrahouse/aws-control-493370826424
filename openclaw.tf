module "openclaw" {
  source  = "registry.infrahouse.com/infrahouse/openclaw/aws"
  version = "0.2.0"

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
}
