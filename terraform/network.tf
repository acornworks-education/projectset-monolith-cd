resource "aws_vpc" "monolith" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "VPC-monolith"
    Service = "monolith"
  }
}

resource "aws_subnet" "public_subnet_monolith" {
  vpc_id                  = aws_vpc.monolith.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"

  tags = {
    Name    = "Subnet-monolith-a"
    Service = "monolith"
  }
}

resource "aws_subnet" "private_subnet_monolith" {
  vpc_id                  = aws_vpc.monolith.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}b"

  tags = {
    Name    = "Subnet-monolith-b"
    Service = "monolith"
  }
}

resource "aws_subnet" "private_subnet_monolith_2" {
  vpc_id                  = aws_vpc.monolith.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "${var.region}c"

  tags = {
    Name    = "Subnet-monolith-b"
    Service = "monolith"
  }
}

resource "aws_internet_gateway" "monolith" {
  vpc_id = aws_vpc.monolith.id

  tags = {
    Name    = "IG-monolith"
    Service = "monolith"
  }
}

resource "aws_eip" "nat_eip" {
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_monolith.id

  tags = {
    Name    = "NATGW-monolith"
    Service = "monolith"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.monolith.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.monolith.id
  }

  tags = {
    Name    = "RT-public-monolith"
    Service = "monolith"
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet_monolith.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.monolith.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name    = "RT-private-monolith"
    Service = "monolith"
  }
}

resource "aws_route_table_association" "private_route_table_assoc" {
  subnet_id      = aws_subnet.private_subnet_monolith.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_route_table_association" "private_route_table_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_monolith_2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for RDS DB instance, allows traffic from EC2 instances"
  vpc_id      = aws_vpc.monolith.id

  ingress {
    from_port       = 5432 # Default port for PostgreSQL
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "SG-DB-monolith"
    Service = "monolith"
  }
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2-security-group"
  description = "Security group for EC2 instance, allows specific traffic"
  vpc_id      = aws_vpc.monolith.id

  # Allow public access on port 65080
  ingress {
    from_port   = 65080
    to_port     = 65080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # AWS Systems Manager (SSM) requires several ports and IP ranges
  # Refer to AWS documentation for the most current requirements
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust according to your security requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "SG-EC2-monolith"
    Service = "monolith"
  }
}
