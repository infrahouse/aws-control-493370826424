module "vpn" {
  source                     = "registry.infrahouse.com/infrahouse/openvpn/aws"
  version                    = "~> 0.2"
  backend_subnet_ids         = module.management.subnet_private_ids
  lb_subnet_ids              = module.management.subnet_public_ids
  google_oauth_client_writer = "arn:aws:iam::990466748045:user/aleks"
  zone_id                    = module.infrahouse_com.infrahouse_zone_id
}
