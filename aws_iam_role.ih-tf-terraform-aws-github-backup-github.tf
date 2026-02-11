## ECR public permissions for CI/CD in the terraform-aws-github-backup repo

data "aws_iam_policy_document" "github-backup-github-permissions" {

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
      aws_ecrpublic_repository.github-backup.arn
    ]
  }

}

resource "aws_iam_policy" "github-backup-github-permissions" {
  provider    = aws.aws-493370826424-uw1
  name        = "github-backup-github-permissions"
  description = "Permissions policy for ih-tf-terraform-aws-github-backup-github role"
  policy      = data.aws_iam_policy_document.github-backup-github-permissions.json
}

resource "aws_iam_role_policy_attachment" "github-backup-github" {
  provider   = aws.aws-493370826424-uw1
  policy_arn = aws_iam_policy.github-backup-github-permissions.arn
  role       = module.registry.registry_client_role_names["terraform-aws-github-backup"]
}
