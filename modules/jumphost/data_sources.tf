data "aws_iam_policy_document" "jumphost_permissions" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_codename}-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "state"
    values = [
      "available"
    ]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  external_facts_dir = "/etc/puppetlabs/facter/facts.d"
}
data "template_cloudinit_config" "jumphost" {
  gzip          = false
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
              },
              {
                content : yamlencode(
                  {
                    puppet_role : "jumphost"
                    puppet_environment : var.environment
                  }
                ),
                path : join(
                  "/", [
                    local.external_facts_dir,
                    "puppet.yaml"
                  ]
                ),
                permissions : "0644"
              }
            ]
            "package_update" : true,
            apt : {
              sources : {
                infrahouse : {
                  source : "deb [signed-by=$KEY_FILE] https://release-${var.ubuntu_codename}.infrahouse.com/ $RELEASE main"
                  key : var.gpg_public_key
                }
              }
            }
            packages : [
              "puppet-code"
            ],
            puppet : {
              install : true,
              install_type : "aio",
              collection : "puppet8",
              package_name : "puppet-agent",
              start_service : false,
            }
            runcmd : [
              [
                "bash", "/opt/puppet-code/modules/profile/files/puppet_apply.sh"
              ]
            ]
          }
        )
      ]
    )
  }
}
