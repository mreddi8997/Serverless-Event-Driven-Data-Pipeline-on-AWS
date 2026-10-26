import {
  to = aws_s3_bucket.test_bucket
  identity = {
    bucket = "this-is-a-test-bucket-1234567890"
  }
}

resource "aws_s3_bucket" "test_bucket" {
  bucket = "this-is-a-test-bucket-1234567890"
}

import {
  to = aws_dynamodb_table.table_db
  identity = {
    name = "servicerequest"
  }
}

resource "aws_dynamodb_table" "table_db" {
  name         = "servicerequest"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "request_id"

  attribute {
    name = "request_id"
    type = "S"
  }

}
