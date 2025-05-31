data "aws_iam_policy_document" "RDSDiscovery" {
  statement {
    actions = [
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "rds-db:connect",
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
    ]
    resources = ["*"]

  }
}

resource "aws_iam_policy" "RDSDiscovery" {
  policy = data.aws_iam_policy_document.RDSDiscovery.json
}
