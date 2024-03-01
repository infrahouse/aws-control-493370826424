# Admin role in this AWS account used by github-control
module "ih-tf-github-control" {
  source      = "infrahouse/github-role/aws"
  version     = "~> 1.0"
  gh_org_name = "infrahouse8"
  repo_name   = "github-control"
}

resource "aws_iam_role_policy_attachment" "test-runner-admin-permissions" {
  policy_arn = data.aws_iam_policy.administrator-access.arn
  role       = module.ih-tf-github-control.github_role_name
}
