output "infrahouse_ns" {
  value = module.infrahouse_com.infrahouse_ns
}

output "infrahouse-website-infra-admin-role" {
  description = "website admin role ARN"
  value       = module.ih-tf-infrahouse-website-infra-admin.admin_role_arn
}

output "infrahouse-website-infra-github-role" {
  description = "website GitHub Actions role ARN"
  value       = module.ih-tf-infrahouse-website-infra-admin.github_role_arn
}
