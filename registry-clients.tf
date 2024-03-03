### IAM roles that can upload to the registry
locals {
  terraform_modules = ["terraform-aws-cloud-init"]
}
module "registry-client-roles" {
  source      = "git::https://github.com/infrahouse/terraform-aws-github-role.git?ref=1.1.0"
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
