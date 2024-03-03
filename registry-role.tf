data "aws_iam_policy_document" "registry_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      values = [
        data.aws_caller_identity.current.account_id
      ]
      variable = "aws:SourceAccount"
    }
    condition {
      test = "ArnLike"
      values = [
        "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      ]
      variable = "aws:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "registry_node_permissions" {
  statement {
    actions = [
      "dynamodb:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "registry_node" {
  name_prefix = "registry-node-"
  policy      = data.aws_iam_policy_document.registry_node_permissions.json
}

resource "aws_iam_role_policy_attachment" "task_role" {
  policy_arn = aws_iam_policy.registry_node.arn
  role       = aws_iam_role.registry-node.name
}

resource "aws_iam_role" "registry-node" {
  name_prefix        = "registry-node-"
  assume_role_policy = data.aws_iam_policy_document.registry_node_assume.json
}
