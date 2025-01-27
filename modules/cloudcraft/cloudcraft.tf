data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["arn:aws:iam::968898580625:root"]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      values   = ["9333c73a-f9e1-4cbb-beb4-39a981e914b6"]
      variable = "sts:ExternalId"
    }
  }
}

resource "aws_iam_role" "cloudcraft-scanner" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  name               = "cloudcraft-scanner"
}

resource "aws_iam_policy" "cloudcraft_permissions" {
  name_prefix = "cloudcraft-"
  policy      = data.aws_iam_policy_document.cloudcraft_permissions.json
}

resource "aws_iam_role_policy_attachment" "cloudcraft_permissions" {
  role       = aws_iam_role.cloudcraft-scanner.name
  policy_arn = aws_iam_policy.cloudcraft_permissions.arn
}

output "cloudcraft-scanner-role-arn" {
  value = aws_iam_role.cloudcraft-scanner.arn
}
output "cloudcraft-scanner-role-name" {
  value = aws_iam_role.cloudcraft-scanner.name
}
