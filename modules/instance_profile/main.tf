resource "aws_iam_policy" "profile" {
  name_prefix = var.profile_name
  policy      = var.permissions
}

resource "aws_iam_role" "profile" {
  name_prefix        = var.profile_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "jumphost" {
  policy_arn = aws_iam_policy.profile.arn
  role       = aws_iam_role.profile.name
}

resource "aws_iam_instance_profile" "profile" {
  name = var.profile_name
  role = aws_iam_role.profile.name
}

resource "aws_iam_role_policy_attachment" "extra" {
  for_each   = toset(var.extra_policies)
  policy_arn = each.value
  role       = aws_iam_role.profile.name
}
