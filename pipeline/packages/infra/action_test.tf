# Setup permission for action

resource "aws_iam_role" "test_role" {
  name               = "infra-pipeline-test-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild_assume.json}"
}

data "aws_iam_policy_document" "test_role_policy" {
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
      "ssm:GetParameters",
    ]

    resources = [
      "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/codepipeline/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "test_role_policy" {
  name   = "infra-pipeline-test"
  role   = "${aws_iam_role.test_role.id}"
  policy = "${data.aws_iam_policy_document.test_role_policy.json}"
}

# CodeBuild project for action
resource "aws_codebuild_project" "test" {
  name        = "prm-infra-test-${var.environment}"
  description = "Test the infrastructure"

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline/packages/infra/spec/test.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  service_role = "${aws_iam_role.test_role.arn}"

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "${var.environment}"
    }

    environment_variable {
      name = "ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
  }

  tags {
    Environment = "prm-${var.environment}"
    Component   = "pipeline"
  }
}
