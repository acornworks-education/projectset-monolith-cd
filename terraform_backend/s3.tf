resource "aws_s3_bucket" "terraform_backend_state" {
  bucket        = "terraform-backend-state-${var.s3_suffix}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "terraform_backend_state" {
  bucket = aws_s3_bucket.terraform_backend_state.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "terraform_backend_state" {
  bucket     = aws_s3_bucket.terraform_backend_state.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.terraform_backend_state]
}

resource "aws_s3_bucket_versioning" "terraform_backend_state" {
  bucket = aws_s3_bucket.terraform_backend_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
