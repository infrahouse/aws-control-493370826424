module "jumphost_profile" {
  source       = "../instance_profile"
  permissions  = data.aws_iam_policy_document.jumphost_permissions.json
  profile_name = "jumphost"
}


resource "aws_launch_template" "jumphost" {
  name_prefix   = "jumphost-"
  instance_type = "t3.nano"
  key_name      = var.keypair_name
  image_id      = var.ami_id == null ? data.aws_ami.ubuntu_22.id : var.ami_id
  iam_instance_profile {
    arn = module.jumphost_profile.instance_profile_arn
  }
}

resource "aws_autoscaling_group" "jumphost" {
  name_prefix         = aws_launch_template.jumphost.name_prefix
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.jumphost.id
    version = aws_launch_template.jumphost.latest_version
  }
  lifecycle {
    create_before_destroy = true
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
  }
}

resource "aws_cloudwatch_event_rule" "scale" {
  name_prefix = "jumphost-scale"
  description = "Jumphost ASG lifecycle hook"
  event_pattern = jsonencode(
    {
      "source" : ["aws.autoscaling"],
      "detail-type" : [
        "EC2 Instance-launch Lifecycle Action",
        "EC2 Instance-terminate Lifecycle Action"
      ],
      "detail" : {
        "AutoScalingGroupName" : [
          aws_autoscaling_group.jumphost.name
        ]
      }
    }
  )
}

resource "aws_cloudwatch_event_target" "scale-out" {
  arn  = aws_lambda_function.update_dns.arn
  rule = aws_cloudwatch_event_rule.scale.name
}


locals {
  lifecycle_hook_wait_time = 300
}

resource "aws_autoscaling_lifecycle_hook" "launching" {
  name                   = "launching"
  autoscaling_group_name = aws_autoscaling_group.jumphost.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
  heartbeat_timeout      = local.lifecycle_hook_wait_time
  default_result         = "CONTINUE"
}

resource "aws_autoscaling_lifecycle_hook" "terminating" {
  name                   = "terminating"
  autoscaling_group_name = aws_autoscaling_group.jumphost.name
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
  heartbeat_timeout      = local.lifecycle_hook_wait_time
  default_result         = "CONTINUE"
}