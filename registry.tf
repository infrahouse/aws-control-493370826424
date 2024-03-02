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
  docker_image          = "pacovk/tapir"
  internet_gateway_id   = module.management.internet_gateway_id
  load_balancer_subnets = module.management.subnet_public_ids
  service_name          = "terraform-registry"
  ssh_key_name          = aws_key_pair.aleks.key_name
  zone_id               = module.infrahouse_com.infrahouse_zone_id
}
