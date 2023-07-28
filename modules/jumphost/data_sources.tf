data "aws_iam_policy_document" "jumphost_permissions" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

data "aws_ami" "ubuntu_22" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "template_cloudinit_config" "jumphost" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = join(
      "\n",
      [
        "#cloud-config",
        yamlencode(
          {
            write_files : [
              {
                content : join(
                  "\n",
                  [
                    "[default]",
                    "region=${data.aws_region.current.name}"
                  ]
                ),
                path : "/root/.aws/config",
                permissions : "0600"
              }
            ]
            "package_update" : true,
            apt : {
              sources : {
                infrahouse : {
                  source : "deb https://release-$RELEASE.infrahouse.com/ $RELEASE main"
                  key : var.gpg_public_key
                }
              }
            }
            puppet : {
              "install" : true,
              "install_type" : "aio",
              "collection" : "puppet8",
              "package_name" : "puppet-agent",
            }
          }
        )
      ]
    )
  }
}
