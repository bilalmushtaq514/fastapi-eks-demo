variable "region" {
  description = "AWS region for state bucket and lock table"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket holding Terraform state. Must be globally unique."
  type        = string
  default     = "tf-state-microservice-dev"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "tf-state-lock"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default = {
    Project   = "microservice"
    ManagedBy = "terraform"
    Purpose   = "tf-state-backend"
  }
}
