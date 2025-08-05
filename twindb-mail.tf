module "mail_twindb_com" {
  source                   = "registry.infrahouse.com/infrahouse/postfix/aws"
  version                  = "0.4.0"
  environment              = var.environment
  keypair_name             = aws_key_pair.aleks.key_name
  asg_max_size             = 1
  asg_min_size             = 1
  on_demand_base_capacity  = 0
  nlb_subnet_ids           = module.management.subnet_public_ids
  route53_zone_id          = aws_route53_zone.twindb_com.zone_id
  route53_hostname         = "mail"
  subnet_ids               = module.management.subnet_private_ids
  puppet_hiera_config_path = "/opt/infrahouse-puppet-data/environments/${var.environment}/hiera.yaml"
  packages = [
    "infrahouse-puppet-data"
  ]
  puppet_custom_facts = {
    postfix : {
      smtp_credentials : module.smtp_credentials.secret_name
    }
  }
}
