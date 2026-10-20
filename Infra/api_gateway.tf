resource "aws_apigatewayv2_api" "service_request_api" {
  name          = "service-request-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "service_request_integration" {
  api_id                 = aws_apigatewayv2_api.service_request_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.query_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "service_request_route" {
  api_id    = aws_apigatewayv2_api.service_request_api.id
  route_key = "GET /request/{request_id}"
  target    = "integrations/${aws_apigatewayv2_integration.service_request_integration.id}"
}

resource "aws_apigatewayv2_stage" "service_request_stage" {
  api_id      = aws_apigatewayv2_api.service_request_api.id
  name        = "$default"
  auto_deploy = true
}

