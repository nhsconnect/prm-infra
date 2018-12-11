resource "aws_codepipeline" "prm-infra-pipeline" {
  name     = "prm-infra-pipeline"
  role_arn = "${aws_iam_role.prm-infra-codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.prm-codebuild-artifact.bucket}"
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
    name = "Build_infrastructure"

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
