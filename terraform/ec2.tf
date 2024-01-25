data "aws_ami" "latest_monolith_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["monolith-ami-*"]
  }
}

resource "aws_instance" "monolith" {
  ami           = data.aws_ami.latest_monolith_ami.id
  instance_type = var.instance_type

  tags = {
    Name    = "EC2-${local.service_name}"
    Service = local.service_name
  }

  # Assuming you are using a key pair
  key_name = var.key_pair_name

  # Security groups (ensure SSH and your application port are open)
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  subnet_id              = aws_subnet.public_subnet_monolith.id
}
