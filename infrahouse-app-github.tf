# GitHub App "InfraHouse" — SaaS platform (infrahouse.app)
#
# Secrets for the GitHub App private key and webhook secret.
# The App ID and installation ID are non-sensitive — stored in SSM Parameter Store.
#
# TODO: add the backend ECS task role ARN to `readers` once the infra is defined.

module "infrahouse-app-github-app-key" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.1.1"
  secret_description = "GitHub App InfraHouse (SaaS) PEM private key"
  secret_name_prefix = "infrahouse-app-github-app-key"
  environment        = local.environment
  writers = [
    local.admin_role_arn
  ]
}

module "infrahouse-app-github-webhook-secret" {
  source             = "registry.infrahouse.com/infrahouse/secret/aws"
  version            = "1.1.1"
  secret_description = "GitHub App InfraHouse (SaaS) webhook secret"
  secret_name_prefix = "infrahouse-app-github-webhook-secret"
  environment        = local.environment
  writers = [
    local.admin_role_arn
  ]
}

resource "aws_ssm_parameter" "infrahouse_app_github_app_id" {
  name        = "/infrahouse-app/github-app/app-id"
  description = "GitHub App InfraHouse (SaaS) — App ID"
  type        = "String"
  value       = "PLACEHOLDER"
}
