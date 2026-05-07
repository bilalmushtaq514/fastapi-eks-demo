terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  # Backend values are filled at init via -backend-config or by editing this file.
  # Bucket and DynamoDB table are created by terraform/bootstrap/.
  backend "s3" {
    bucket         = "tf-state-microservice-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
  }
}
