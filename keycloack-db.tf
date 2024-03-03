resource "aws_db_instance" "keycloack" {
  instance_class              = "db.t3.micro"
  identifier_prefix           = "keycloack-"
  allocated_storage           = 10
  max_allocated_storage       = 100
  db_name                     = "keycloack"
  engine                      = "mysql"
  engine_version              = "8.0"
  manage_master_user_password = true
  username                    = "keycloack_dba"
  db_subnet_group_name        = aws_db_subnet_group.keycloack.name
  multi_az                    = true
  backup_retention_period     = 7
  deletion_protection         = true
  vpc_security_group_ids = [
    aws_security_group.keycloack.id
  ]
}

resource "aws_db_subnet_group" "keycloack" {
  name_prefix = "keycloack"
  subnet_ids  = module.management.subnet_private_ids
}

resource "aws_security_group" "keycloack" {
  description = "keycloack RDS instance"
  name_prefix = "keycloack-db-"
  vpc_id      = module.management.vpc_id
  tags = {
    Name : "keycloack RDS"
  }
}

resource "aws_vpc_security_group_ingress_rule" "keycloack-mysql" {
  description       = "Allow mysql traffic"
  security_group_id = aws_security_group.keycloack.id
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
  cidr_ipv4         = module.management.vpc_cidr_block
  tags = {
    Name = "mysql access"
  }
}

resource "aws_vpc_security_group_ingress_rule" "keycloack-icmp" {
  description       = "Allow all ICMP traffic"
  security_group_id = aws_security_group.keycloack.id
  from_port         = -1
  to_port           = -1
  ip_protocol       = "icmp"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "ICMP traffic"
  }
}

resource "aws_vpc_security_group_egress_rule" "keycloack_outgoing" {
  security_group_id = aws_security_group.keycloack.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  tags = {
    Name = "outgoing traffic"
  }
}
