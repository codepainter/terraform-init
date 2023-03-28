data "aws_caller_identity" "current" {}

locals {
  account_id   = data.aws_caller_identity.current.account_id
  project_code = var.project_code
  environment  = var.environment
}

##################################
# Init Terraform State S3 Bucket #
##################################
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.project_code}-terraform-states-${local.account_id}"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [
    aws_s3_bucket.terraform_state
  ]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [
    aws_s3_bucket.terraform_state,
  ]
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [
    aws_s3_bucket.terraform_state
  ]
}

#################################
# Init Terraform State DynamoDB #
#################################

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "${local.project_code}-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}

##########################################################################
# Uncomment the terraform block below and run "terraform init" (again)   #
# after the initial terraform init has been run to enable the S3 backend #
##########################################################################
# terraform {
#   backend "s3" {
#     bucket = "ntb-terraform-states-870952867497"
#     key    = "init/terraform.tfstate"
#     region = "ap-southeast-1"

#     dynamodb_table = "ntb-terraform-locks"
#     encrypt        = true
#   }
# }
