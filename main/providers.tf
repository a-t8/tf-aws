terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "atul-terraform-state"
    key            = "main/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "tf-state-locker"
  }
}

provider "aws" {
  region  = "us-west-2"
}
