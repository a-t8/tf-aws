terraform {


  backend "s3" {

    key     = "atul-terraform-state/terraform.tfstate"
    region  = "us-west-2"
    profile = "iamadmin-general"
  }
}


resource "aws_s3_bucket" "atul_state_bucket" {
  bucket        = "atul-terraform-state"
  acl           = "private"
  force_destroy = false

  tags = {
    Name = "atul-terraform-state"

  }
}

resource "aws_dynamodb_table" "atul_lock_table" {
  name           = "tf-state-locker"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  table_class    = "STANDARD"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "tf-state-locker"

  }
}

