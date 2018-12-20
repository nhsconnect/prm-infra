resource "aws_codebuild_webhook" "codebuild-prm-webhook" {
  project_name = "${aws_codebuild_project.prm-vcs-trigger.name}"
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
    type      = "BITBUCKET"
    location  = "https://bitbucket.org/twnhsd/walking-skeleton-spikes.git"
    buildspec = "./webhook.yml"
  }
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
