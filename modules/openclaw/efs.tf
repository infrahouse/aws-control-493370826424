# ------------------------------------------------------------------------------
# EFS for persistent OpenClaw data
#
# Survives instance replacement, AZ failure, and ASG termination.
# Mounted at /home/openclaw/.openclaw for agent data persistence.
# ------------------------------------------------------------------------------

resource "aws_efs_file_system" "this" {
  creation_token = "${var.service_name}-data"
  encrypted      = true
  kms_key_id     = data.aws_kms_key.efs_default.arn

  tags = {
    Name        = "${var.service_name}-data"
    environment = var.environment
    service     = var.service_name
  }
}

resource "aws_efs_backup_policy" "this" {
  file_system_id = aws_efs_file_system.this.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "this" {
  for_each       = toset(var.backend_subnet_ids)
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = each.key
  security_groups = [
    aws_security_group.efs.id
  ]
}

# --- EFS security group ---

resource "aws_security_group" "efs" {
  description = "EFS volume for ${var.service_name} data"
  name_prefix = "${var.service_name}-efs-"
  vpc_id      = data.aws_subnet.backend[var.backend_subnet_ids[0]].vpc_id

  tags = {
    Name        = "${var.service_name}-efs"
    environment = var.environment
    service     = var.service_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs_nfs" {
  for_each          = toset(var.backend_subnet_ids)
  description       = "Allow NFS from backend subnets"
  security_group_id = aws_security_group.efs.id
  from_port         = 2049
  to_port           = 2049
  ip_protocol       = "tcp"
  cidr_ipv4         = data.aws_subnet.backend[each.key].cidr_block

  tags = {
    Name        = "NFS from ${each.key}"
    environment = var.environment
    service     = var.service_name
  }
}

resource "aws_vpc_security_group_egress_rule" "efs" {
  security_group_id = aws_security_group.efs.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name        = "EFS outgoing"
    environment = var.environment
    service     = var.service_name
  }
}
