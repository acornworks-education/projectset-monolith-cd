module "dynamodb_default" {
  source      = "./modules"
  lock_id_key = local.lock_id_key
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
