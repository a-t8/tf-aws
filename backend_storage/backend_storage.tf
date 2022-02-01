resource "aws_s3_bucket" "atul_state_bucket" {
  bucket        = "atul-tiwari-tf-state-bucket"
  acl           = "private"
  force_destroy = false

  tags = {
    Name = "atul-tiwari-tf-state-bucket"
  }
}

resource "aws_dynamodb_table" "atul-tf-table" {
  name           = "atul-tf-table"
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
    Name = "atul-tf-table"
  }
}
