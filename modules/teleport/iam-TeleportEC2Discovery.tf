data "aws_iam_policy_document" "TeleportEC2Discovery" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ssm:DescribeInstanceInformation",
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
      "ssm:SendCommand"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "TeleportEC2Discovery" {
  policy = data.aws_iam_policy_document.TeleportEC2Discovery.json
}
