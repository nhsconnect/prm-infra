resource "aws_s3_bucket" "prm-codebuild-artifact" {
  bucket        = "prm-${data.aws_caller_identity.current.account_id}-codebuild-artifact"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "prm-codebuild-lambda-artifact" {
  bucket        = "prm-${data.aws_caller_identity.current.account_id}-codebuild-lambda-artifact"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_iam_role" "codebuild-project-generic-role" {
  name               = "codebuild-project-generic-role"
  assume_role_policy = "${file("${path.module}/codebuild-project-generic-role.json")}"
}

resource "aws_iam_policy" "codebuild-project-generic-assume-role-policy" {
  name   = "codebuild-project-generic-assume-role-policy"
  policy = "${file("${path.module}/codebuild-project-generic-assume-role-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "codebuild-project-generic-assume-role-attachment" {
  role       = "${aws_iam_role.codebuild-project-generic-role.name}"
  policy_arn = "${aws_iam_policy.codebuild-project-generic-assume-role-policy.arn}"
}
