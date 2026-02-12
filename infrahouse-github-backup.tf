module "infrahouse-github-backup-app-key" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.1.1"
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
