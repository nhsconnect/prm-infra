# Setup permissions for action

resource "aws_iam_role" "build_role" {
  name               = "infra-pipeline-build-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume.json}"
}

data "aws_iam_policy_document" "build_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["${var.iam_role}"]
  }
}

resource "aws_iam_role_policy" "build_role_policy" {
  name   = "infra-pipeline-build"
  role   = "${aws_iam_role.build_role.id}"
  policy = "${data.aws_iam_policy_document.build_role_policy.json}"
}

# Create the CodeBuild project for the action

resource "aws_codebuild_project" "build" {
  name        = "prm-infra-build-${var.environment}"
  description = "Build the infrastructure"

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline/packages/infra/spec/build.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  service_role = "${aws_iam_role.build_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "431593652018.dkr.ecr.eu-west-2.amazonaws.com/codebuild/terraform:0.2.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "${var.environment}"
    }

    environment_variable {
      name  = "ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
  }

  tags {
    Environment = "prm-${var.environment}"
    Component   = "pipeline"
  }
}