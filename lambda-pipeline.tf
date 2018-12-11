resource "aws_codepipeline" "lambda-pipeline" {
  name = "lambda-pipeline"
  role_arn = "${aws_iam_role.prm-lambda-codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.prm-infra-codepipeline-bucket.bucket}"
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
        S3Bucket  = "${var.prm-application-source-bucket}"
        S3ObjectKey   = "source/latest.zip"
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
