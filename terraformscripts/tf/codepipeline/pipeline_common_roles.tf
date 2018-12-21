# Role for generic Project
resource "aws_iam_role" "codebuild-project-generic-role" {
  name               = "codebuild-project-generic-role"
  assume_role_policy = "${file("${path.module}/codebuild-project-generic-role.json")}"
}

# Assume-role policy for generic project role
resource "aws_iam_policy" "codebuild-project-generic-assume-role-policy" {
  name   = "codebuild-project-generic-assume-role-policy"
  policy = "${file("${path.module}/codebuild-project-generic-assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "codebuild-project-generic-assume-role-attachment" {
  role       = "${aws_iam_role.codebuild-project-generic-role.name}"
  policy_arn = "${aws_iam_policy.codebuild-project-generic-assume-role-policy.arn}"
}

# Service policy for generic project role
resource "aws_iam_policy" "codebuild-project-generic-service-policy" {
  name   = "codebuild-project-generic-service-policy"
  policy = "${file("${path.module}/codebuild-project-generic-service-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "codebuild-project-generic-service-attachment" {
  role       = "${aws_iam_role.codebuild-project-generic-role.name}"
  policy_arn = "${aws_iam_policy.codebuild-project-generic-service-policy.arn}"
}

# Role for generic Pipeline
resource "aws_iam_role" "codepipeline-generic-role" {
  name               = "codepipeline-generic-role"
  assume_role_policy = "${file("${path.module}/codepipeline-generic-role.json")}"
}

resource "aws_iam_role_policy_attachment" "codepipeline-generic-role-attachment" {
  role       = "${aws_iam_role.codepipeline-generic-role.name}"
  policy_arn = "${aws_iam_policy.codepipeline-generic-policy.arn}"
}

resource "aws_iam_policy" "codepipeline-generic-policy" {
  name = "codepipeline-generic-policy"

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
        "${aws_s3_bucket.prm-codebuild-lambda-artifact.arn}",
        "${aws_s3_bucket.prm-codebuild-lambda-artifact.arn}/*",
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
