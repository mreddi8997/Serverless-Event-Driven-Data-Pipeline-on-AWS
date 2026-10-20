resource "aws_iam_role" "processing_lambda_role" {
  name = "service-request-processing-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "processing_lambda_policy_attachment" {
  role       = aws_iam_role.processing_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "processing_lambda_access" {
  name = "service-request-lambda-access"
  role = aws_iam_role.processing_lambda_role.id


  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.test_bucket.arn}/incoming/*"
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.table_db.arn
      },
      {
        Action = [
          "sqs:SendMessage"
        ]
        Effect   = "Allow"
        Resource = aws_sqs_queue.service-request-processing-dlq.arn
      }

    ]
  })

}


resource "aws_iam_role" "query_lambda_role" {
  name = "service-request-query-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_role_policy_attachment" "query_lambda_policy_attachment" {
  role       = aws_iam_role.query_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "query_lambda_access" {
  name = "service-request-query-lambda-access"
  role = aws_iam_role.query_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.table_db.arn
      }
    ]
  })

}