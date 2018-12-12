resource "aws_codepipeline" "lambda-pipeline" {
  name     = "lambda-pipeline"
  role_arn = "${aws_iam_role.prm-lambda-codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.prm-codebuild-artifact.bucket}"
    type     = "S3"
  }

  stage {
    name = "source-lambdas-stage"

    action {
      name             = "source-lambdas-action"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        S3Bucket    = "${var.prm-application-source-bucket}"
        S3ObjectKey = "source-walking-skeleton-spikes/latest.zip"
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
        ProjectName = "${aws_codebuild_project.prm-build-ehr-extract-lambda.name}"
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
        ProjectName = "${aws_codebuild_project.prm-build-uptime-monitor-lambda.name}"
      }
    }
  }
}

resource "aws_iam_role" "prm-lambda-codepipeline" {
  name = "lambda-role"

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

resource "aws_iam_role_policy" "prm-lambda-codepipeline-policy" {
  name = "prm-lambda-codepipeline-policy"
  role = "${aws_iam_role.prm-lambda-codepipeline.id}"

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
        "${aws_s3_bucket.prm-codebuild-artifact.arn}",
        "${aws_s3_bucket.prm-codebuild-artifact.arn}/*",
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

resource "aws_codebuild_project" "prm-build-uptime-monitor-lambda" {
  name          = "prm-build-uptime-monitor-lambda"
  description   = "Builds uptime monitoring"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-lambda-build-role.arn}"

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
    buildspec = "./terraformscripts/codepipeline/lambdas_uptime_monitoring.yml"
  }
}

resource "aws_codebuild_project" "prm-build-ehr-extract-lambda" {
  name          = "prm-build-ehr-extract-lambda"
  description   = "Builds EhrExtract"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-lambda-build-role.arn}"

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
    buildspec = "./terraformscripts/codepipeline/lambdas_ehr_extract_handler.yml"
  }
}

resource "aws_iam_role" "codebuild-lambda-build-role" {
  name = "codebuild-lambda-build-role"

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

resource "aws_iam_role_policy" "codebuild-lambda-build-policy" {
  role = "${aws_iam_role.codebuild-lambda-build-role.name}"

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
