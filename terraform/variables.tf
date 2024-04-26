variable "region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-northeast-2"
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "The name of the key pair to attach to the EC2 instance"
  type        = string
}

variable "db_instance_type" {
  description = "The instance type of the RDS database"
  type        = string
  default     = "db.t2.micro"
}

variable "pem_file_location" {
  description = "PEM file location"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}
