module "registry" {
  source  = "registry.infrahouse.com/infrahouse/registry/aws"
  version = "0.4.0"

  providers = {
    aws = aws
  }

  service_name = "terraform-registry-2"
  environment  = var.environment

  subnets_backend  = module.management.subnet_private_ids
  subnets_frontend = module.management.subnet_public_ids

  zone_id           = module.infrahouse_com.infrahouse_zone_id
  registry_hostname = "registry"

  cognito_users = [
    {
      email     = "aleks@infrahouse.com"
      full_name = "Oleksandr Kuzminskyi"
    }
  ]
  terraform_modules = local.terraform_modules
}
