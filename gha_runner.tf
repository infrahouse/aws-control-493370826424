module "actions-runner-pem" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.1.1"
  secret_description = "GitHub App PEM key for actions-runner"
  secret_name_prefix = "actions-runner-pem"
  environment        = local.environment
  readers = [
    "arn:aws:iam::493370826424:role/actions-runner-*",
  ]
  writers = [
    local.admin_role_arn
  ]
}

module "actions-runner-noble" {
  source  = "registry.infrahouse.com/infrahouse/actions-runner/aws"
  version = "4.0.0"
  providers = {
    aws = aws.aws-493370826424-uw1
  }

  environment                = local.environment
  github_org_name            = "infrahouse"
  github_app_id              = 1016363
  github_app_pem_secret_arn  = module.actions-runner-pem.secret_arn
  subnet_ids                 = module.management.subnet_private_ids
  role_name                  = "actions-runner-noble"
  instance_type              = "t3a.small"
  root_volume_size           = 64
  max_instance_lifetime_days = 7
  asg_min_size               = 1
  on_demand_base_capacity    = 0
  ubuntu_codename            = "noble"
  extra_labels               = ["noble"]
  puppet_hiera_config_path   = "/opt/infrahouse-puppet-data/environments/${local.environment}/hiera.yaml"
  packages = [
    "debhelper",
    "devscripts",
    "infrahouse-puppet-data",
    "golang",
    "packer",
    "skeema",
  ]
  alarm_emails = local.alarm_emails
}
