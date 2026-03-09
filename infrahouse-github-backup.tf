module "infrahouse-github-backup-app-key" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.1.1"
  secret_description = "GitHub App infrahouse-github-backup PEM key"
  secret_name_prefix = "infrahouse-github-backup"
  environment        = local.environment
  readers = [
    "arn:aws:iam::493370826424:role/infrahouse-github-backup"
  ]
  writers = [
    data.aws_iam_role.AWSAdministratorAccess.arn
  ]
}

module "github-backup" {
  source  = "registry.infrahouse.com/infrahouse/github-backup/aws"
  version = "2.0.1"
  providers = {
    aws = aws.aws-493370826424-uw1
  }

  github_app_id              = "1016509"
  github_app_installation_id = "55611573"

  alarm_emails   = local.alarm_emails
  replica_region = "us-east-1"
  subnets        = module.management.subnet_private_ids

  github_app_key_secret_writers = [
    data.aws_iam_role.AWSAdministratorAccess.arn
  ]

  environment = local.environment
}
