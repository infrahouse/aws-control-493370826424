data "aws_iam_policy" "administrator-access" {
  provider = aws.aws-493370826424-uw1
  name     = "AdministratorAccess"
}

data "aws_availability_zones" "uw1" {
  provider = aws.aws-493370826424-uw1
  state    = "available"
}
