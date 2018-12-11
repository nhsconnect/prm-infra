variable "prm-application-source-bucket" {}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.ehr_extract_handler.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_deployment.api_gw_deployment.execution_arn}/*/*"
}

resource "aws_iam_policy_attachment" "lambda-exec-policy-attachment" {
  name       = "PlanOneLambdaExecPolicy"
  roles      = ["${aws_iam_role.lambda_exec.id}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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

resource "aws_lambda_permission" "allow_cloudwatch_to_call_uptime_monitoring_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.uptime_monitoring.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_min_rule.arn}"
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
        "arn:aws:s3:::${var.prm-application-source-bucket}",
        "arn:aws:s3:::${var.prm-application-source-bucket}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "prm-vcs-trigger" {
  name          = "prm-vcs-trigger"
  description   = "The trigger to start the PRM pipelines (because pipeline doesn't integrate with BitBucket)"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-trigger-service-role.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/python:3.6.5"
    type         = "LINUX_CONTAINER"
  }

  source {
    type            = "BITBUCKET"
    location        = "https://bitbucket.org/twnhsd/walking-skeleton-spikes.git"
    git_clone_depth = 1
    buildspec       = "webhook_trigger.yml"
  }
}

resource "aws_iam_role" "codebuild-prm-infra-plan-role" {
  name                  = "codebuild-prm-infra-plan-role"
  force_detach_policies = true

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

resource "aws_iam_role" "codebuild-prm-ehr-extract-role" {
  name = "codebuild-prm-ehr-extract-role"

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

resource "aws_iam_role_policy" "codebuild-prm-ehr-extract-policy" {
  role = "${aws_iam_role.codebuild-prm-ehr-extract-role.name}"

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
  name          = "prm-infra-plan"
  description   = "Validates the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-infra-plan-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/python:3.6.5"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "infra_plan.yml"
  }
}

resource "aws_codebuild_project" "prm-build-uptime-monitor" {
  name          = "prm-build-uptime-monitor"
  description   = "Builds uptime monitoring"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-uptime-monitoring-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/python:3.6.5"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "uptime_monitoring.yml"
  }
}

resource "aws_codebuild_project" "prm-build-ehr-extract" {
  name          = "prm-build-ehr-extract"
  description   = "Builds EhrExtract"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-ehr-extract-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/python:3.6.5"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "ehr_extract_handler.yml"
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
  name          = "prm-infra-apply"
  description   = "Applies the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-infra-apply-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/python:3.6.5"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "infra_apply.yml"
  }
}

resource "aws_iam_role" "codebuild-prm-infra-validate-role" {
  name = "codebuild-prm-infra-valdiate-role"

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

resource "aws_iam_role_policy" "codebuild-prm-infra-validate-service-policy" {
  role = "${aws_iam_role.codebuild-prm-infra-validate-role.name}"

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

resource "aws_codebuild_project" "prm-infra-validate" {
  name          = "prm-infra-validate"
  description   = "Validates the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-infra-validate-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "PRM_ENDPOINT"
      "value" = "${aws_api_gateway_deployment.api_gw_deployment.invoke_url}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "infra_validate.yml"
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
        "arn:aws:s3:::${var.prm-application-source-bucket}",
        "arn:aws:s3:::${var.prm-application-source-bucket}/*"
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
  bucket        = "prm-infra-codepipeline-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "uptime_monitoring_bucket" {
  bucket        = "uptime-monitoring-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
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
        S3Bucket    = "${var.prm-application-source-bucket}"
        S3ObjectKey = "source/latest.zip"
      }
    }
  }

  stage {
    name = "Build-Lambdas"

    action {
      name            = "Build-Ehr-Extract"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-ehr-extract.name}"
      }
    }

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

  stage {
    name = "Dev_Integration"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-infra-plan.name}"
      }
    }

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 2

      configuration {
        ProjectName = "${aws_codebuild_project.prm-infra-apply.name}"
      }
    }

    action {
      name            = "Validate"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 3

      configuration {
        ProjectName = "${aws_codebuild_project.prm-infra-validate.name}"
      }
    }
  }
}
