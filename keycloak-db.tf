resource "aws_db_instance" "keycloak" {
  instance_class              = "db.t3.micro"
  identifier_prefix           = "keycloak-"
  allocated_storage           = 10
  max_allocated_storage       = 100
  db_name                     = "keycloak"
  engine                      = "mysql"
  engine_version              = "8.0"
  manage_master_user_password = true
  username                    = "keycloak_dba"
  db_subnet_group_name        = aws_db_subnet_group.keycloak.name
  multi_az                    = true
  backup_retention_period     = 7
  deletion_protection         = true
  vpc_security_group_ids = [
    aws_security_group.keycloak.id
  ]
  iam_database_authentication_enabled = true
  apply_immediately                   = true
}

resource "aws_db_subnet_group" "keycloak" {
  name_prefix = "keycloak"
  subnet_ids  = module.management.subnet_private_ids
}

resource "aws_security_group" "keycloak" {
  description = "keycloak RDS instance"
  name_prefix = "keycloak-db-"
  vpc_id      = module.management.vpc_id
  tags = {
    Name : "keycloak RDS"
  }
}

resource "aws_vpc_security_group_ingress_rule" "keycloak-mysql" {
  description       = "Allow mysql traffic"
  security_group_id = aws_security_group.keycloak.id
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
  cidr_ipv4         = module.management.vpc_cidr_block
  tags = {
    Name = "mysql access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "keycloak-icmp" {
  description       = "Allow all ICMP traffic"
  security_group_id = aws_security_group.keycloak.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "ICMP traffic"
  }
}

resource "aws_vpc_security_group_egress_rule" "keycloak_outgoing" {
  security_group_id = aws_security_group.keycloak.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "outgoing traffic"
  }
}

locals {
  kc_db_username = "keycloak_service"
}

resource "random_password" "keycloak_service" {
  length = 21
}
