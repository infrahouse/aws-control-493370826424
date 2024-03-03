resource "aws_secretsmanager_secret" "keycloak_admin_creds" {
  provider                = aws.aws-493370826424-uw1
  name_prefix             = "keycloak_admin_credentials"
  description             = "A json with username/password keys with keycloak credentials"
  recovery_window_in_days = 0
}

resource "random_pet" "keycloak_admin_username" {}
resource "random_password" "keycloak_admin_password" {
  length = 21
}

resource "aws_secretsmanager_secret_version" "keycloak_admin_creds" {
  provider  = aws.aws-493370826424-uw1
  secret_id = aws_secretsmanager_secret.keycloak_admin_creds.id
  secret_string = jsonencode(
    {
      username : random_pet.keycloak_admin_username.id
      password : random_password.keycloak_admin_password.result
    }
  )
}

module "keycloak" {
  source = "git::https://github.com/infrahouse/terraform-aws-ecs.git?ref=2.6.1"
  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.dns = aws.aws-493370826424-uw1
  }
  asg_subnets = module.management.subnet_private_ids
  dns_names = [
    "auth"
  ]
  docker_image                  = "quay.io/keycloak/keycloak:23.0.7"
  internet_gateway_id           = module.management.internet_gateway_id
  load_balancer_subnets         = module.management.subnet_public_ids
  service_name                  = "auth"
  ssh_key_name                  = aws_key_pair.aleks-Black-MBP.key_name
  zone_id                       = module.infrahouse_com.infrahouse_zone_id
  container_healthcheck_command = "ls || exit 1"
  container_command             = ["start"]
  alb_healthcheck_path          = "/"
  asg_instance_type             = "t3.small"
  asg_max_size                  = 2
  alb_healthcheck_interval      = 60
  container_memory              = "512"
  task_environment_variables = [
    {
      name : "KEYCLOAK_ADMIN"
      value : random_pet.keycloak_admin_username.id
    },
    {
      name : "KEYCLOAK_ADMIN_PASSWORD"
      value : random_password.keycloak_admin_password.result
    },
    {
      name : "KC_HOSTNAME"
      value : "auth.${module.infrahouse_com.infrahouse_zone_name}"
    },
    {
      name : "KC_HTTP_ENABLED"
      value : true
    },
    {
      name : "KC_HEALTH_ENABLED"
      value : true
    },
    {
      name : "KC_HTTPS_PORT"
      value : 443
    }
  ]
}
