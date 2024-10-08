module "infrahouse-github-backup-app-key" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "~> 0.6"
  secret_description = "GitHub App infrahouse-github-backup PEM key"
  secret_name_prefix = "infrahouse-github-backup"
  environment        = var.environment
  readers = [
    module.jumphost.jumphost_role_arn
  ]
  writers = [
    data.aws_iam_role.AWSAdministratorAccess.arn
  ]
}
