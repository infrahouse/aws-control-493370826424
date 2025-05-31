module "infrahouse-github-backup-app-key" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.0.1"
  secret_description = "GitHub App infrahouse-github-backup PEM key"
  secret_name_prefix = "infrahouse-github-backup"
  environment        = var.environment
  readers = [
    "arn:aws:iam::493370826424:role/infrahouse-github-backup"
  ]
  writers = [
    data.aws_iam_role.AWSAdministratorAccess.arn
  ]
}

module "terraform-aws-github-backup" {
  source                   = "registry.infrahouse.com/infrahouse/github-backup/aws"
  version                  = "0.6.4"
  app_key_secret           = module.infrahouse-github-backup-app-key.secret_name
  subnets                  = module.management.subnet_private_ids
  instance_type            = "t3a.small"
  environment              = var.environment
  puppet_hiera_config_path = "/opt/infrahouse-puppet-data/environments/${var.environment}/hiera.yaml"
  root_volume_size         = 60
  packages = [
    "infrahouse-puppet-data"
  ]
  smtp_credentials_secret = module.smtp_credentials.secret_name
}
