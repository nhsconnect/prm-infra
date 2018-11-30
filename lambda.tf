terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_lambda_function" "ehr_extract_handler" {
  function_name = "EhrExtractHandler"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = "terraform-serverless-kc4"
  s3_key = "example.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "nodejs6.10"

  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  parent_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.root_resource_id}"
  path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_resource.proxy.id}"
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.ehr_extract_handler.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.root_resource_id}"
  http_method = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = "${aws_lambda_function.ehr_extract_handler.invoke_arn}"
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    "aws_api_gateway_integration.lambda",
    "aws_api_gateway_integration.lambda_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  stage_name = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ehr_extract_handler.function_name}"
  principal = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.example.execution_arn}/*/*"
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "notify-error-4xx" {
  alarm_name = "terraform-test-notify-error-4xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "4XXError"
  namespace = "AWS/ApiGateway"
  period = "60"
  statistic = "Sum"
  threshold = "0"
  alarm_description = "This metric monitors 4xx errors on API-gateway"
  insufficient_data_actions = []

  dimensions {
    ApiName = "${aws_lambda_function.ehr_extract_handler.function_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "notify-error-5xx" {
  alarm_name = "terraform-test-notify-error-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "5XXError"
  namespace = "AWS/ApiGateway"
  period = "60"
  statistic = "Sum"
  threshold = "0"
  alarm_description = "This metric monitors 5xx errors on API-gateway"
  insufficient_data_actions = []

  dimensions {
    ApiName = "${aws_lambda_function.ehr_extract_handler.function_name}"
  }
}

// Setting CodeBuild
//resource "aws_s3_bucket" "terraform-serverless-kc4" {
//  bucket = "terraform-serverless-kc4"
//  acl = "private"
//}

resource "aws_codebuild_webhook" "codebuild-prm-webhook" {
  project_name = "${aws_codebuild_project.prm-vcs-trigger.name}"
}

resource "aws_iam_role" "codebuild-prm-trigger-service-role" {
  name = "codebuild-prm-trigger-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild-prm-trigger-service-policy" {
  role = "${aws_iam_role.codebuild-prm-trigger-service-role.name}"

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
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:s3:::codepipeline-eu-west-2-*"
      ],
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-serverless-kc4",
        "arn:aws:s3:::terraform-serverless-kc4/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "prm-vcs-trigger" {
  name = "prm-vcs-trigger"
  description = "The trigger to start the PRM pipelines (because pipeline doesn't integrate with BitBucket)"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild-prm-trigger-service-role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "S3"
    location = "${aws_lambda_function.ehr_extract_handler.s3_bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/python:3.6.5"
    type = "LINUX_CONTAINER"
  }

  source {
    type = "BITBUCKET"
    location = "https://bitbucket.org/twnhsd/walking-skeleton-spikes.git"
    git_clone_depth = 1
    buildspec = "webhook_trigger.yml"
  }
}