module "cloudcraft" {
  source = "./modules/cloudcraft"
}

output "cloudcraft-scanner-role-arn" {
  value = module.cloudcraft.cloudcraft-scanner-role-arn
}

output "cloudcraft-scanner-role-name" {
  value = module.cloudcraft.cloudcraft-scanner-role-name
}
