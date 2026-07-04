locals {
  environment = "production"
  dr_region   = "us-east-1"
  alarm_emails = [
    "aleks@infrahouse.com"
  ]

  terraform_admin_role_arn = "arn:aws:iam::493370826424:role/ih-tf-aws-control-493370826424-admin"
  admin_role_arn           = tolist(data.aws_iam_roles.AWSAdministratorAccess.arns)[0]
}
