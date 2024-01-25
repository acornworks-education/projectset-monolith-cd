resource "aws_db_instance" "monolith" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = var.db_instance_type
  db_name                = local.service_name
  username               = "dbuser"
  password               = "yoursecurepassword"
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.monolith.id

  tags = {
    Name    = "DB-${local.service_name}"
    Service = local.service_name
  }
}

resource "aws_db_subnet_group" "monolith" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_monolith.id, aws_subnet.private_subnet_monolith_2.id]

  tags = {
    Name    = "DBSG-${local.service_name}"
    Service = local.service_name
  }
}
