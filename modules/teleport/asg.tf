module "userdata" {
  source                   = "registry.infrahouse.com/infrahouse/cloud-init/aws"
  version                  = "1.16.0"
  environment              = var.environment
  role                     = "teleport"
  puppet_debug_logging     = var.puppet_debug_logging
  puppet_environmentpath   = var.puppet_environmentpath
  puppet_hiera_config_path = var.puppet_hiera_config_path
  puppet_module_path       = var.puppet_module_path
  puppet_root_directory    = var.puppet_root_directory
  puppet_manifest          = var.puppet_manifest
  ubuntu_codename          = var.ubuntu_codename
  packages = concat(
    [
      "awscli",
      "nfs-common"
    ]
  )

  custom_facts = merge(
    var.puppet_custom_facts,
    {
      teleport : {
        proxy_public_addr : local.cluster_name
        storage_table_name : aws_dynamodb_table.teleport.name
        audit_bucket_name : aws_s3_bucket.teleport.bucket
        cluster_name : local.cluster_name
        aws_account_id : data.aws_caller_identity.current.account_id
        discover_regions : [
          data.aws_region.current.name,
          "us-east-1",
        ]
        github_client_id : var.github_client_id
        github_client_secret_secret_name : var.github_client_secret_secret_name
        teams_to_roles : var.teams_to_roles
      }
    },
  )
}

resource "tls_private_key" "teleport" {
  algorithm = "RSA"
}

resource "aws_key_pair" "teleport" {
  key_name_prefix = "teloport-generated-"
  public_key      = tls_private_key.teleport.public_key_openssh
  tags            = local.default_module_tags
}

resource "aws_key_pair" "mediapc" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDpgAP1z1Lxg9Uv4tam6WdJBcAftZR4ik7RsSr6aNXqfnTj4civrhd/q8qMqF6wL//3OujVDZfhJcffTzPS2XYhUxh/rRVOB3xcqwETppdykD0XZpkHkc8XtmHpiqk6E9iBI4mDwYcDqEg3/vrDAGYYsnFwWmdDinxzMH1Gei+NPTmTqU+wJ1JZvkw3WBEMZKlUVJC/+nuv+jbMmCtm7sIM4rlp2wyzLWYoidRNMK97sG8+v+mDQol/qXK3Fuetj+1f+vSx2obSzpTxL4RYg1kS6W1fBlSvstDV5bQG4HvywzN5Y8eCpwzHLZ1tYtTycZEApFdy+MSfws5vPOpggQlWfZ4vA8ujfWAF75J+WABV4DlSJ3Ng6rLMW78hVatANUnb9s4clOS8H6yAjv+bU3OElKBkQ10wNneoFIMOA3grjPvPp5r8dI0WDXPIznJThDJO5yMCy3OfCXlu38VDQa1sjVj1zAPG+Vn2DsdVrl50hWSYSB17Zww0MYEr8N5rfFE= aleks@MediaPC"
}

resource "aws_launch_template" "teleport" {
  name_prefix   = "teleport-"
  instance_type = "t3a.micro"
  # key_name      = aws_key_pair.teleport.key_name
  key_name = aws_key_pair.mediapc.key_name
  image_id = data.aws_ami.ubuntu_pro.id
  iam_instance_profile {
    arn = module.instance_profile.instance_profile_arn
  }
  metadata_options {
    http_tokens            = "required"
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
  block_device_mappings {
    device_name = data.aws_ami.selected.root_device_name
    ebs {
      volume_size           = 30
      delete_on_termination = true
    }
  }
  user_data = module.userdata.userdata
  tags      = local.default_module_tags
  vpc_security_group_ids = [
    aws_security_group.backend.id
  ]
  tag_specifications {
    resource_type = "volume"
    tags = merge(
      data.aws_default_tags.provider.tags,
      local.default_module_tags
    )
  }
  tag_specifications {
    resource_type = "network-interface"
    tags = merge(
      data.aws_default_tags.provider.tags,
      local.default_module_tags
    )
  }

}

resource "random_string" "suffix" {
  length  = 6
  special = false
}
locals {
  asg_name = "${aws_launch_template.teleport.name}-${random_string.suffix.result}"
}

resource "aws_autoscaling_group" "teleport" {
  name                      = local.asg_name
  min_size                  = var.asg_min_size == null ? length(var.backend_subnet_ids) : var.asg_min_size
  max_size                  = var.asg_max_size == null ? length(var.backend_subnet_ids) + 1 : var.asg_max_size
  vpc_zone_identifier       = var.backend_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 900
  max_instance_lifetime     = 90 * 24 * 3600
  dynamic "launch_template" {
    for_each = var.on_demand_base_capacity == null ? [1] : []
    content {
      id      = aws_launch_template.teleport.id
      version = aws_launch_template.teleport.latest_version
    }
  }
  dynamic "mixed_instances_policy" {
    for_each = var.on_demand_base_capacity == null ? [] : [1]
    content {
      instances_distribution {
        on_demand_base_capacity                  = var.on_demand_base_capacity
        on_demand_percentage_above_base_capacity = 0
      }
      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.teleport.id
          version            = aws_launch_template.teleport.latest_version
        }
      }
    }
  }
  target_group_arns = [
    aws_alb_target_group.teleport.arn
  ]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 100
    }
  }
  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "teleport"
  }
  dynamic "tag" {
    for_each = merge(
      local.default_module_tags,
      data.aws_default_tags.provider.tags
    )

    content {
      key                 = tag.key
      propagate_at_launch = true
      value               = tag.value
    }
  }
}
