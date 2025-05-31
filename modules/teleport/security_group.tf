resource "aws_security_group" "external" {
  name_prefix = "teleport-external"
  description = "Allow HTTPS traffic"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allow HTTP traffic from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend" {
  name_prefix = "teleport-backend"
  description = "Allow All traffic within the security group"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    description = "Allow all traffic inside the security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow SSH from the VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      data.aws_vpc.selected.cidr_block
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
