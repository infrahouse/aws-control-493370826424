data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
    ]
    resources = [
      aws_cloudwatch_log_group.update_dns.arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"
    ]
  }
}

data "aws_iam_policy_document" "lambda-permissions" {
  statement {
    actions = ["autoscaling:CompleteLifecycleAction"]
    resources = [
      aws_autoscaling_group.jumphost.arn
    ]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name_prefix = "lambda_logging"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_policy" "lambda_permissions" {
  name_prefix = "lambda_permissions"
  description = "IAM policy for a lambda permissions"
  policy      = data.aws_iam_policy_document.lambda-permissions.json
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  policy_arn = aws_iam_policy.lambda_permissions.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_lambda_function" "update_dns" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "update_dns"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.9"
  depends_on = [
    data.archive_file.lambda,
  ]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch-out"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_dns.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scale.arn

}

resource "aws_cloudwatch_log_group" "update_dns" {
  name              = "/aws/lambda/${aws_lambda_function.update_dns.function_name}"
  retention_in_days = 14
}