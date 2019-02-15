# Setup permissions for action

resource "aws_iam_role" "test_update_role" {
  name               = "infra-pipeline-test-update-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume.json}"
}

data "aws_iam_policy_document" "test_update_role_policy" {
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
    effect = "Allow"

    actions = [
      "codebuild:UpdateProject",
    ]

    resources = [
      "arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.current.account_id}:project/prm-infra-test-${var.environment}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:CreateSecurityGroup"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "test_update_role_policy" {
  name   = "infra-pipeline-test-update"
  role   = "${aws_iam_role.test_update_role.id}"
  policy = "${data.aws_iam_policy_document.test_update_role_policy.json}"
}

# Create the CodeBuild project

resource "aws_codebuild_project" "test_update" {
  name        = "prm-infra-test-update"
  description = "Update the test project with VPC details"

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline/packages/infra/spec/test_update.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  service_role = "${aws_iam_role.test_update_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/python:3.6.5"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "${var.environment}"
    }
  }

  tags {
    Environment = "prm-${var.environment}"
    Component   = "pipeline"
  }
}
