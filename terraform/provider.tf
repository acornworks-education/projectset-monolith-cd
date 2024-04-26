terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  # Variables may not be used here.
  backend "s3" {
    bucket         = "terraform-backend-state-fb0f9062"
    region         = "ap-norththeast-2"
    dynamodb_table = "terraform_state_lock"
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}