module "dynamodb_default" {
  source      = "./modules"
  providers = {
    aws = aws
  }
}

module "dynamodb_staging" {
  source      = "./modules"
  providers = {
    aws = aws.staging
  }
}
