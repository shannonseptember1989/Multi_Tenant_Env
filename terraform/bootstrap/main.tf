# =============================================================================
# terraform/bootstrap/main.tf
# =============================================================================
# ONE-TIME SETUP — run this manually BEFORE running the pipeline for the first time.
#
# Creates the S3 bucket and DynamoDB table that store Terraform remote state.
# These must exist before Ansible can run `terraform init` with the S3 backend.
#
# HOW TO RUN
#   cd terraform/bootstrap
#   terraform init
#   terraform plan  -var="state_bucket_name=mycompany-tf-state"
#   terraform apply -var="state_bucket_name=mycompany-tf-state"
#
# AFTER APPLYING
# Copy the outputs into ansible/environments/*/vars.yml:
#   tf_state_bucket: <state_bucket_name output>
#   tf_lock_table:   <lock_table_name output>
# =============================================================================

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = var.state_bucket_name
    Purpose   = "terraform-remote-state"
    ManagedBy = "terraform-bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name      = var.lock_table_name
    Purpose   = "terraform-state-lock"
    ManagedBy = "terraform-bootstrap"
  }
}
