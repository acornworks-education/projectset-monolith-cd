resource "aws_dynamodb_table" "terraform_s3_backend_lock" {
  name           = "terraform_state_lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = local.lock_id_key

  attribute {
    name = local.lock_id_key
    type = "S"
  }

  tags = {
    Description = "Terraform S3 Backend State Locking"
  }
}