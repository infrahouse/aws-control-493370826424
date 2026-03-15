locals {
  environment              = "production"
  alarm_emails             = ["aleks@infrahouse.com"]
  terraform_admin_role_arn = "arn:aws:iam::493370826424:role/ih-tf-aws-control-493370826424-admin"
  admin_role_arn           = tolist(data.aws_iam_roles.AWSAdministratorAccess.arns)[0]
  openclaw_users = [
    {
      email     = "aleks@infrahouse.com"
      full_name = "Oleksandr Kuzminskyi"
    }
  ]
}
