resource "random_string" "profile-suffix" {
  length  = 6
  special = false
}

module "instance_profile" {
  source       = "registry.infrahouse.com/infrahouse/instance-profile/aws"
  version      = "1.8.1"
  profile_name = "teleport-${random_string.profile-suffix.result}"
  role_name    = "teleport-${random_string.profile-suffix.result}"
  permissions  = data.aws_iam_policy_document.default_permissions.json
  extra_policies = merge(
    {
      ssm : data.aws_iam_policy.ssm.arn
      dynamodb : aws_iam_policy.dynamodb.arn
      s3 : aws_iam_policy.s3.arn
      TeleportEC2Discovery : aws_iam_policy.TeleportEC2Discovery.arn
      TeleportEC2DiscoveryBoundary : aws_iam_policy.TeleportEC2DiscoveryBoundary.arn
      RDSDiscovery : aws_iam_policy.RDSDiscovery.arn
    }
  )
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "default_permissions" {
  statement {
    actions = [
      "sts:GetCallerIdentity",
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "autoscaling:SetInstanceHealth",
    ]
    resources = [
      join(
        ":",
        [
          "arn",
          "aws",
          "autoscaling",
          data.aws_region.current.name,
          data.aws_caller_identity.current.account_id,
          "autoScalingGroup",
          "*",
          "autoScalingGroupName/${local.asg_name}"
        ]
      )
    ]
  }

}

data "aws_iam_policy_document" "dynamodb" {
  statement {
    actions = [
      "dynamodb:BatchWriteItem",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:DescribeStream",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DescribeTable",
      "dynamodb:GetShardIterator",
      "dynamodb:GetItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:UpdateTable",
      "dynamodb:GetRecords",
      "dynamodb:UpdateContinuousBackups"
    ]
    resources = [
      aws_dynamodb_table.teleport.arn,
      "${aws_dynamodb_table.teleport.arn}/stream/*"
    ]
  }
}

resource "aws_iam_policy" "dynamodb" {
  policy = data.aws_iam_policy_document.dynamodb.json
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.teleport.arn,
      "${aws_s3_bucket.teleport.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3" {
  policy = data.aws_iam_policy_document.s3.json
}
