module "ecs" {
  source = "git::https://github.com/infrahouse/terraform-aws-ecs.git?ref=2.6.1"
  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.dns = aws.aws-493370826424-uw1
  }
  asg_subnets = module.management.subnet_private_ids
  dns_names = [
    "registry"
  ]
  docker_image                  = "pacovk/tapir"
  internet_gateway_id           = module.management.internet_gateway_id
  load_balancer_subnets         = module.management.subnet_public_ids
  service_name                  = "terraform-registry"
  ssh_key_name                  = aws_key_pair.aleks-Black-MBP.key_name
  zone_id                       = module.infrahouse_com.infrahouse_zone_id
  container_healthcheck_command = "curl -f http://localhost:8080/ || exit 1"
  task_environment_variables = [
    {
      name : "AUTH_ENDPOINT"
      value : jsondecode(
        data.aws_secretsmanager_secret_version.registry_client_secret.secret_string
      )["auth_uri"]
    },
    {
      name : "AUTH_CLIENT_ID"
      value : jsondecode(
        data.aws_secretsmanager_secret_version.registry_client_secret.secret_string
      )["client_id"]
    },
    {
      name : "AUTH_CLIENT_SECRET"
      value : jsondecode(
        data.aws_secretsmanager_secret_version.registry_client_secret.secret_string
      )["client_secret"]
    }
  ]
}


resource "aws_secretsmanager_secret" "registry_client_secret" {
  provider                = aws.aws-493370826424-uw1
  name_prefix             = "registry_client_secret"
  description             = "Oauth2 credentials with Google"
  recovery_window_in_days = 0
}

data "aws_secretsmanager_secret_version" "registry_client_secret" {
  provider  = aws.aws-493370826424-uw1
  secret_id = aws_secretsmanager_secret.registry_client_secret.id
}

