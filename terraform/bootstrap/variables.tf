variable "aws_region" {
  description = "AWS region to create the state backend resources in"
  type        = string
  default     = "eu-centre-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state. Must be globally unique."
  type        = string
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-state-lock"
}
