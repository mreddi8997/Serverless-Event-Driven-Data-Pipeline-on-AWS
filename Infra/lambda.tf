resource "aws_lambda_function" "processing_lambda" {
  function_name = "process-service-request"
  role          = aws_iam_role.processing_lambda_role.arn
  handler       = "s3_lambda.lambda_handler"
  runtime       = "python3.14"
  timeout       = 30

  dead_letter_config {
    target_arn = aws_sqs_queue.service-request-processing-dlq.arn

  }

  filename         = "s3_lambda.zip"
  source_code_hash = filebase64sha256("s3_lambda.zip")

  environment {
    variables = {
      S3_BUCKET_NAME      = aws_s3_bucket.test_bucket.bucket
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.table_db.name
    }
  }


  depends_on = [aws_iam_role_policy.processing_lambda_access, aws_iam_role_policy_attachment.processing_lambda_policy_attachment]
}



resource "aws_lambda_permission" "s3_event_permission" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processing_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.test_bucket.arn
}

resource "aws_s3_bucket_notification" "s3_event_notification" {
  bucket = aws_s3_bucket.test_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processing_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "incoming/"
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.s3_event_permission]
}


resource "aws_lambda_function" "query_lambda" {
  function_name = "query-service-request"
  role          = aws_iam_role.query_lambda_role.arn
  handler       = "query_lambda.lambda_handler"
  runtime       = "python3.14"
  timeout       = 30

  filename         = "query_lambda.zip"
  source_code_hash = filebase64sha256("query_lambda.zip")

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.table_db.name
    }
  }

  depends_on = [aws_iam_role_policy.query_lambda_access, aws_iam_role_policy_attachment.query_lambda_policy_attachment]
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.query_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.service_request_api.execution_arn}/*/GET/request/*"
}