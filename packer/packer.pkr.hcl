packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  default = "ap-northeast-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "source_ami_filter_name" {
  default = "amzn2-ami-hvm-*-x86_64-gp2"
}

source "amazon-ebs" "monolith" {
  region        = var.aws_region
  instance_type = var.instance_type
  source_ami_filter {
    filters = {
      "virtualization-type" = "hvm"
      "name"                = var.source_ami_filter_name
      "root-device-type"    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  ssh_username = "ec2-user"
  ami_name     = "monolith-ami-${formatdate("YYYYMMDDHHmmss", timestamp())}"
}

build {
  sources = [
    "source.amazon-ebs.monolith"
  ]

  provisioner "file" {
    source      = "./monolith.jar"
    destination = "/home/ec2-user/monolith.jar"
  }

  provisioner "file" {
    source      = "./monolith.service"
    destination = "/home/ec2-user/monolith.service"
  }

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y java-11-amazon-corretto"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y java-11-amazon-corretto",
      "echo 'Java and Corretto installed'",
      "sudo cp /home/ec2-user/monolith.service /etc/systemd/system/monolith.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable monolith.service",
      "sudo systemctl start monolith.service",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo 'Waiting for the Java application to start...'",
      "timeout 60 bash -c 'until journalctl -u monolith.service --since \"1 minute ago\" | grep -m 1 \"Started ProjectsetApplication\"; do sleep 1; done' && exit 0 || exit 1",
      "echo 'Service check completed...'"
    ]
  }
}
