module "teleport" {
  source              = "./modules/teleport"
  backend_subnet_ids  = module.management.subnet_private_ids
  environment         = var.environment
  frontend_subnet_ids = module.management.subnet_public_ids
  zone_id             = module.infrahouse_com.infrahouse_zone_id

  asg_min_size = 1
  asg_max_size = 1

  teams_to_roles = [
    {
      "organization" : "infrahouse",
      "team" : "developers",
      "roles" : ["access", "editor"],
    }
  ]
  github_client_id                 = "Ov23litM1y0qjRrl6ZwA"
  github_client_secret_secret_name = module.teleport_github_app_secret.secret_name
}

module "teleport_github_app_secret" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.0.1"
  secret_description = "Github App Client secret for Teleport"
  secret_name_prefix = "teleport_github_app_secret"
  environment        = var.environment
  writers = [
    data.aws_iam_role.AWSAdministratorAccess.arn,
  ]
  readers = [
    module.teleport.teleport_role_arn,
  ]
}
