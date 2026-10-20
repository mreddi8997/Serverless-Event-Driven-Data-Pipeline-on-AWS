resource "aws_sns_topic" "user-updates-topic" {
  name = "user-updates-topic"
}

resource "aws_sns_topic_subscription" "user_updates_email_target" {
  topic_arn = aws_sns_topic.user-updates-topic.arn
  protocol  = "email"
  endpoint  = "mohitredi293@gmail.com"
}

resource "aws_cloudwatch_metric_alarm" "AWS_SQS_Alarm" {
  alarm_name                = "SQS_Alarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "ApproximateNumberOfMessagesVisible"
  namespace                 = "AWS/SQS"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 0
  alarm_description         = "This metric monitors SQS queue length"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.user-updates-topic.arn]
  treat_missing_data        = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.service-request-processing-dlq.name
  }

}

data "aws_caller_identity" "current" {}

resource "aws_sns_topic_policy" "service_request_sns_policy" {
  arn = aws_sns_topic.user-updates-topic.arn

  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [

      "SNS:Publish"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_metric_alarm.AWS_SQS_Alarm.arn]
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.user-updates-topic.arn,
    ]

    sid = "__default_statement_ID"
  }
}