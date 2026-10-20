resource "aws_sqs_queue" "service-request-processing-dlq" {
  name                      = "service-request-processing-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true

}

