resource "null_resource" "install_python_dependencies" {
  provisioner "local-exec" {
    command = "bash ${path.module}/package_update_dns.sh"
    environment = {
      TARGET_DIR        = "${path.module}/update_dns"
      REQUIREMENTS_FILE = "${path.module}/update_dns/requirements.txt"
    }
  }
  depends_on = [
    null_resource.clean_up
  ]
  triggers = {
    dependencies = filemd5("${path.module}/update_dns/requirements.txt")
    code         = filemd5("${path.module}/update_dns/main.py")
  }
}

resource "null_resource" "clean_up" {
  provisioner "local-exec" {
    command = "rm -f ${path.module}/update_dns.zip"
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/update_dns"
  output_path = "${path.module}/update_dns.zip"
  depends_on = [
    null_resource.install_python_dependencies
  ]
}
