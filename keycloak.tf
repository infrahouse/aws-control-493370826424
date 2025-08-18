resource "random_pet" "keycloak_admin_username" {}
resource "random_password" "keycloak_admin_password" {
  length = 21
}

module "keycloak" {
  source  = "registry.infrahouse.com/infrahouse/ecs/aws"
  version = "5.8.2"
  providers = {
    aws     = aws.aws-493370826424-uw1
    aws.dns = aws.aws-493370826424-uw1
  }
  asg_subnets = module.management.subnet_private_ids
  dns_names = [
    "auth"
  ]
  docker_image                  = "quay.io/keycloak/keycloak:23.0.7"
  ami_id                        = "ami-0b661dc3de2dae64f"
  internet_gateway_id           = module.management.internet_gateway_id
  load_balancer_subnets         = module.management.subnet_public_ids
  service_name                  = "auth"
  ssh_key_name                  = aws_key_pair.aleks-Black-MBP.key_name
  zone_id                       = module.infrahouse_com.infrahouse_zone_id
  container_healthcheck_command = "ls || exit 1"
  container_command             = ["start"]
  healthcheck_path              = "/health"
  asg_instance_type             = "t3.small"
  asg_min_size                  = 1
  asg_max_size                  = 1
  task_min_count                = 1
  on_demand_base_capacity       = 0
  healthcheck_interval          = 60
  container_memory              = "512"
  task_environment_variables = [
    {
      name : "KEYCLOAK_ADMIN"
      value : random_pet.keycloak_admin_username.id
    },
    {
      name : "KC_PROXY"
      value : "edge"
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
    },
    {
      name : "KC_HOSTNAME_ADMIN_URL"
      value : "https://auth.${module.infrahouse_com.infrahouse_zone_name}"
    },
    {
      name : "KC_DB"
      value : aws_db_instance.keycloak.engine
    },
    {
      name : "KC_DB_SCHEMA"
      value : aws_db_instance.keycloak.db_name
    },
    {
      name : "KC_DB_URL_HOST"
      value : aws_db_instance.keycloak.address
    },
    {
      name : "KC_DB_URL_PORT"
      value : aws_db_instance.keycloak.port
    },
    {
      name : "KC_DB_USERNAME"
      value : local.kc_db_username
    }
  ]
  task_secrets = [
    {
      name : "KEYCLOAK_ADMIN_PASSWORD"
      valueFrom : module.keycloak_admin_password.secret_arn
    },
    {
      name : "KC_DB_PASSWORD"
      valueFrom : module.kc_db_password.secret_arn
    },
  ]
}

module "keycloak_admin_password" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.0.1"
  secret_description = "Keycloak admin password"
  secret_name_prefix = "keycloak_admin_password"
  environment        = var.environment
  secret_value       = random_password.keycloak_admin_password.result
  readers = [
    module.keycloak.task_execution_role_arn
  ]
}

module "kc_db_password" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.0.1"
  secret_description = "Keycloak DB password"
  secret_name_prefix = "keycloak_db_password"
  secret_value       = random_password.keycloak_service.result
  environment        = var.environment
  readers = [
    module.keycloak.task_execution_role_arn
  ]
}
