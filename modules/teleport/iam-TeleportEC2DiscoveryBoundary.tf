data "aws_iam_policy_document" "TeleportEC2DiscoveryBoundary" {
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

resource "aws_iam_policy" "TeleportEC2DiscoveryBoundary" {
  policy = data.aws_iam_policy_document.TeleportEC2DiscoveryBoundary.json
}
