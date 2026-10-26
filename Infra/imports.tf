removed {
  from = aws_s3_bucket.test_bucket

  lifecycle {
    destroy = false
  }
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
