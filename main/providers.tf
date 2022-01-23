terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "atul--uw2-tf-bucket"
    key            = "main/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "atul-tf-table"
  }
}

provider "aws" {
  region = "us-west-2"
}
