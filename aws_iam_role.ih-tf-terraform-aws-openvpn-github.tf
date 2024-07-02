## Roles for CI/CD in the terraform-aws-openvpn repo

data "aws_iam_policy_document" "openvpn-github-permissions" {

  statement {
    actions = [
      "ecr-public:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]
  }
  statement {
    actions = ["ecr-public:*"]
    resources = [
      aws_ecrpublic_repository.openvpn-portal.arn
    ]
  }

}

resource "aws_iam_policy" "openvpn-github-permissions" {
  provider    = aws.aws-493370826424-uw1
  name        = "openvpn-github-permissions"
  description = "Permissions policy for ih-tf-terraform-aws-openvpn-github role"
  policy      = data.aws_iam_policy_document.openvpn-github-permissions.json
}

resource "aws_iam_role_policy_attachment" "openvpn-github" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = aws_iam_policy.openvpn-github-permissions.arn
  role       = module.registry-client-roles["terraform-aws-openvpn"].github_role_name
}
