### IAM roles that can upload to the registry
locals {
  terraform_modules = [
    "terraform-aws-actions-runner",
    "terraform-aws-bookstack",
    "terraform-aws-ci-cd",
    "terraform-aws-cloudcraft-role",
    "terraform-aws-cloud-init",
    "terraform-aws-cost-alert",
    "terraform-aws-debian-repo",
    "terraform-aws-dms",
    "terraform-aws-ecr",
    "terraform-aws-ecs",
    "terraform-aws-elasticsearch",
    "terraform-aws-gh-identity-provider",
    "terraform-aws-gha-admin",
    "terraform-aws-github-backup",
    "terraform-aws-github-backup-configuration",
    "terraform-aws-github-role",
    "terraform-aws-guardduty-configuration",
    "terraform-aws-iso27001",
    "terraform-aws-instance-profile",
    "terraform-aws-jumphost",
    "terraform-aws-kibana",
    "terraform-aws-openvpn",
    "terraform-aws-postfix",
    "terraform-aws-pypiserver",
    "terraform-aws-secret",
    "terraform-aws-secret-policy",
    "terraform-aws-service-network",
    "terraform-aws-state-bucket",
    "terraform-aws-sqs-ecs",
    "terraform-aws-sqs-pod",
    "terraform-aws-state-manager",
    "terraform-aws-tags-override",
    "terraform-aws-tcp-pod",
    "terraform-aws-teleport",
    "terraform-aws-terraformer",
    "terraform-aws-truststore",
    "terraform-aws-update-dns",
    "terraform-aws-website-pod"
  ]
}
module "registry-client-roles" {
  source      = "registry.infrahouse.com/infrahouse/github-role/aws"
  version     = "~> 1.1"
  for_each    = toset(local.terraform_modules)
  gh_org_name = "infrahouse"
  repo_name   = each.key
}

resource "aws_iam_role_policy_attachment" "registry-client" {
  for_each   = toset(local.terraform_modules)
  policy_arn = aws_iam_policy.registry-client.arn
  role       = module.registry-client-roles[each.key].github_role_name
}

resource "aws_iam_policy" "registry-client" {
  name_prefix = "registry-client"
  policy      = data.aws_iam_policy_document.registry-client-permissions.json
}

data "aws_dynamodb_table" "DeployKeys" {
  name = "DeployKeys"
}

data "aws_iam_policy_document" "registry-client-permissions" {
  statement {
    actions = [
      "dynamodb:GetItem"
    ]
    resources = [
      data.aws_dynamodb_table.DeployKeys.arn
    ]
  }
}
