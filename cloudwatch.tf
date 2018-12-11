resource "aws_cloudwatch_metric_alarm" "prm-gateway-error-4xx" {
  alarm_name = "prm-gateway-error-4xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "4XXError"
  namespace = "AWS/ApiGateway"
  period = "300"
  statistic = "Sum"
  threshold = "0"
  alarm_description = "This metric monitors 4xx errors on API-gateway"
  insufficient_data_actions = []

  dimensions {
    ApiName = "${aws_api_gateway_rest_api.ehr_extract_handler_api.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "prm-gateway-error-5xx" {
  alarm_name = "prm-gateway-error-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "5XXError"
  namespace = "AWS/ApiGateway"
  period = "300"
  statistic = "Sum"
  threshold = "0"
  alarm_description = "This metric monitors 5xx errors on API-gateway"
  insufficient_data_actions = []

  dimensions {
    ApiName = "${aws_api_gateway_rest_api.ehr_extract_handler_api.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "prm-lambda-ehr_extract_handler-error" {
  alarm_name = "prm-lambda-ehr_extract_handler-error"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "1"
  metric_name = "Errors"
  namespace = "AWS/Lambda"
  period = "300"
  statistic = "Sum"
  threshold = "0"
  alarm_description = "This metric monitors errors on ehr_extract_handler lambda"
  insufficient_data_actions = []

  dimensions {
    FunctionName = "${aws_lambda_function.ehr_extract_handler.function_name}"
    Resource = "${aws_lambda_function.ehr_extract_handler.function_name}"
  }
}

resource "aws_cloudwatch_event_rule" "every_min_rule" {
  name = "every-minute"
  description = "Fires every minute"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "every_minute_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_min_rule.name}"
  arn = "${aws_lambda_function.uptime_monitoring.arn}"
}

resource "aws_iam_role" "cloudwatch-apigateway-log-role" {
  name = "cloudwatch-apigateway-log-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch-apigateway-log-policy" {
  role = "${aws_iam_role.cloudwatch-apigateway-log-role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "logs:PutLogEvents",
        "logs:GetLogEvents",
        "logs:FilterLogEvents"
      ]
    }
  ]
}
POLICY
}
