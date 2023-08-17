output "infrahouse_ns" {
  value = module.infrahouse_com.infrahouse_ns
}

output "gha_role_arn" {
  description = "ARN of a GitHub Actions worker role."
  value       = module.ih-tf-aws-control-493370826424-admin.github_role_arn
}

output "admin_role_arn" {
  description = "ARN of a role that can manage resources via terraform."
  value       = module.ih-tf-aws-control-493370826424-admin.admin_role_arn
}
