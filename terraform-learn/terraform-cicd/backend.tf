terraform {
  backend "s3" {
    bucket         = var.s3_bucket_name
    key            = "terraform/state"
    region         = var.aws_region
    dynamodb_table = var.dynamodb_table_name
  }
}
