terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_lambda_function" "ehr_extract_handler" {
  function_name = "EhrExtractHandler"
  s3_bucket = "terraform-serverless-kc4"
  s3_key = "example.zip"
  handler = "main.handler"
  runtime = "nodejs6.10"
  role = "${aws_iam_role.lambda_exec.arn}"
}

resource "aws_lambda_function" "uptime_monitoring" {
  function_name = "UptimeMonitoring"
  s3_bucket = "${aws_s3_bucket.uptime_monitoring_bucket.bucket}"
  s3_key = "uptime_monitoring.zip"
  handler = "main.handler"
  runtime = "nodejs6.10"
  role = "${aws_iam_role.lambda_exec.arn}"

  environment {
    variables = {
      url = "${aws_api_gateway_deployment.example.invoke_url}"
    }
  }

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

resource "aws_api_gateway_method_settings" "s" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  stage_name  = "test"
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.ehr_extract_handler_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type = "MOCK"
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
  type = "MOCK"
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
    ApiName = "${aws_api_gateway_rest_api.ehr_extract_handler_api.name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "notify-error-5xx" {
  alarm_name = "terraform-test-notify-error-5xx"
  comparison_operator = "GreaterThanOrEqualToThreshold"
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

resource "aws_cloudwatch_event_rule" "every_three_mins_rule" {
  name = "every-minute"
  description = "Fires every three minutes"
  schedule_expression = "rate(3 minutes)"
}

resource "aws_cloudwatch_event_target" "every_three_minutes_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_three_mins_rule.name}"
//  target_id = "check_pinger"
  arn = "${aws_lambda_function.uptime_monitoring.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_uptime_monitoring_lambda" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.uptime_monitoring.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.every_three_mins_rule.arn}"
}

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

resource "aws_iam_role" "codebuild-prm-infra-plan-role" {
  name = "codebuild-prm-infra-plan-role"

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

resource "aws_iam_role_policy" "codebuild-prm-infra-plan-service-policy" {
  role = "${aws_iam_role.codebuild-prm-infra-plan-role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [    
    {
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:UpdateEventSourceMapping",
        "lambda:ListFunctions",
        "apigateway:*",
        "s3:*",
        "lambda:GetEventSourceMapping",
        "logs:*",
        "lambda:GetAccountSettings",
        "lambda:CreateEventSourceMapping",
        "codebuild:*",
        "iam:*",
        "cloudwatch:*",
        "kms:*",
        "ssm:*",
        "codedeploy:*",
        "lambda:*",
        "lambda:ListEventSourceMappings",
        "ec2:*",
        "codepipeline:*",
        "lambda:DeleteEventSourceMapping",
        "events:*"
      ],
      "Resource": "*"
    }    
  ]
}
POLICY
}
resource "aws_iam_role" "codebuild-prm-uptime-monitoring-role" {
  name = "codebuild-prm-uptime-monitoring-role"

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

resource "aws_iam_role_policy" "codebuild-prm-uptime-monitoring-policy" {
  role = "${aws_iam_role.codebuild-prm-uptime-monitoring-role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:UpdateEventSourceMapping",
        "lambda:ListFunctions",
        "apigateway:*",
        "s3:*",
        "lambda:GetEventSourceMapping",
        "logs:*",
        "lambda:GetAccountSettings",
        "lambda:CreateEventSourceMapping",
        "codebuild:*",
        "iam:*",
        "cloudwatch:*",
        "kms:*",
        "ssm:*",
        "codedeploy:*",
        "lambda:*",
        "lambda:ListEventSourceMappings",
        "ec2:*",
        "codepipeline:*",
        "lambda:DeleteEventSourceMapping",
        "events:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "prm-infra-plan" {
  name = "prm-infra-plan"
  description = "Validates the infrastructure"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild-prm-infra-plan-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/python:3.6.5"
    type = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "infra_validate.yml"
  }
}
resource "aws_codebuild_project" "prm-build-uptime-monitor" {
  name = "prm-build-uptime-monitor"
  description = "Builds uptime monitoring"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild-prm-uptime-monitoring-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/python:3.6.5"
    type = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "uptime_monitoring.yml"
  }
}

resource "aws_iam_role" "codebuild-prm-infra-apply-role" {
  name = "codebuild-prm-infra-apply-role"

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

resource "aws_iam_role_policy" "codebuild-prm-infra-apply-service-policy" {
  role = "${aws_iam_role.codebuild-prm-infra-apply-role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:CreateFunction",
        "lambda:UpdateEventSourceMapping",
        "lambda:ListFunctions",
        "apigateway:*",
        "s3:*",
        "lambda:GetEventSourceMapping",
        "logs:*",
        "lambda:GetAccountSettings",
        "lambda:CreateEventSourceMapping",
        "codebuild:*",
        "iam:*",
        "cloudwatch:*",
        "kms:*",
        "ssm:*",
        "codedeploy:*",
        "lambda:*",
        "lambda:ListEventSourceMappings",
        "ec2:*",
        "codepipeline:*",
        "lambda:DeleteEventSourceMapping",
        "events:*"
      ],
      "Resource": "*"
    }  
  ]
}
POLICY
}

resource "aws_codebuild_project" "prm-infra-apply" {
  name = "prm-infra-apply"
  description = "Applies the infrastructure"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild-prm-infra-apply-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/python:3.6.5"
    type = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
    buildspec = "infra_apply.yml"
  }
}

resource "aws_iam_role" "prm-infra-codepipeline" {
  name = "test-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "prm-infra-codepipeline-policy" {
  name = "prm-infra-codepipeline-policy"
  role = "${aws_iam_role.prm-infra-codepipeline.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"      
      ],
      "Resource": [
        "${aws_s3_bucket.prm-infra-codepipeline-bucket.arn}",
        "${aws_s3_bucket.prm-infra-codepipeline-bucket.arn}/*",
        "arn:aws:s3:::terraform-serverless-kc4",
        "arn:aws:s3:::terraform-serverless-kc4/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "prm-infra-codepipeline-bucket" {
  bucket = "prm-codepipeline-bucket"
  acl    = "private"
  versioning {
    enabled = true
  }  
}

resource "aws_s3_bucket" "uptime_monitoring_bucket" {
  bucket = "uptime-monitoring-bucket"
  acl    = "private"
//  versioning {
//    enabled = true
//  }
}

resource "aws_codepipeline" "prm-infra-pipeline" {
  name     = "prm-infra-pipeline"
  role_arn = "${aws_iam_role.prm-infra-codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.prm-infra-codepipeline-bucket.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        S3Bucket  = "terraform-serverless-kc4"
        S3ObjectKey   = "source/latest.zip"
      }
    }
  }

  stage {
    name = "Plan"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
 
      configuration {
        ProjectName = "${aws_codebuild_project.prm-infra-plan.name}"
      }
    }
  }

  stage {
    name = "Apply"

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
 
      configuration {
        ProjectName = "${aws_codebuild_project.prm-infra-apply.name}"
      }
    }
  }
  stage {
    name = "Build-Uptime-Monitor"

    action {
      name            = "Build-Uptime-Monitor"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-uptime-monitor.name}"
      }
    }
  }
}