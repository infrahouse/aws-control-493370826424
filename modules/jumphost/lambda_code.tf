locals {
  lambda_root = "${path.module}/update_dns"
}
resource "null_resource" "install_python_dependencies" {
  provisioner "local-exec" {
    command = "bash ${path.module}/package_update_dns.sh"
    environment = {
      TARGET_DIR        = local.lambda_root
      MODULE_DIR        = path.module
      REQUIREMENTS_FILE = "${local.lambda_root}/requirements.txt"
    }
  }
  triggers = {
    dependencies_version = filemd5("${local.lambda_root}/requirements.txt")
    main_version         = filemd5("${local.lambda_root}/main.py")
  }
}

resource "random_uuid" "lamda_src_hash" {
  keepers = {
    for filename in setunion(
      fileset(local.lambda_root, "main.py"),
      fileset(local.lambda_root, "requirements.txt")
    ) :
    filename => filemd5("${local.lambda_root}/${filename}")
  }
}

data "archive_file" "lambda" {
  type = "zip"
  excludes = [
    "__pycache__"
  ]
  source_dir  = "${path.module}/update_dns"
  output_path = "${path.module}/${random_uuid.lamda_src_hash.result}.zip"
  depends_on = [
    null_resource.install_python_dependencies
  ]
}

resource "aws_s3_bucket" "lambda_tmp" {
  bucket_prefix = "infrahouse-jumphost-lambda-"
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.lambda_tmp.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "lambda_package" {
  bucket = aws_s3_bucket.lambda_tmp.bucket
  key    = basename(data.archive_file.lambda.output_path)
  source = data.archive_file.lambda.output_path
  provisioner "local-exec" {
    interpreter = ["timeout", "60", "bash", "-c"]
    command     = <<EOF
aws sts get-caller-identity
echo "provider's role = ${data.aws_caller_identity.current.arn}"
while true
do
  ih-plan \
    --bucket "${aws_s3_bucket.lambda_tmp.bucket}" \
    --aws-assume-role-arn "${data.aws_caller_identity.current.arn}" \
    download \
    "${basename(data.archive_file.lambda.output_path)}" \
    /dev/null && break
  echo 'Waiting until the archive is available'
  sleep 1
done
EOF
  }
}
