# Role for generic Project
resource "aws_iam_role" "codebuild-project-generic-role" {
  name               = "codebuild-project-generic-role"
  assume_role_policy = "${file("${path.module}/codebuild-project-generic-role.json")}"
}

# Assume-role policy for generic project role
data "template_file" "codebuild-project-generic-assume-role-policy" {
  template = "${file("${path.module}/codebuild-project-generic-assume-role-policy.json")}"

  vars {
    ROLE = "${var.role_arn}"
  }
}

resource "aws_iam_policy" "codebuild-project-generic-assume-role-policy" {
  name   = "codebuild-project-generic-assume-role-policy"
  policy = "${data.template_file.codebuild-project-generic-assume-role-policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "codebuild-project-generic-assume-role-attachment" {
  role       = "${aws_iam_role.codebuild-project-generic-role.name}"
  policy_arn = "${aws_iam_policy.codebuild-project-generic-assume-role-policy.arn}"
}

# Service policy for generic project role
resource "aws_iam_policy" "codebuild-project-generic-service-policy" {
  name   = "codebuild-project-generic-service-policy"
  policy = "${data.template_file.codebuild-project-generic-service-policy.rendered}"
}

data "template_file" "codebuild-project-generic-service-policy" {
  template = "${file("${path.module}/codebuild-project-generic-service-policy.json")}"

  vars {
    AWS_REGION     = "${var.aws_region}"
    AWS_ACCOUNT_ID = "${data.aws_caller_identity.current.account_id}"
  }
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
  name   = "codepipeline-generic-policy"
  policy = "${data.template_file.codepipeline-generic-policy.rendered}"
}

data "template_file" "codepipeline-generic-policy" {
  template = "${file("${path.module}/codepipeline-generic-policy.json")}"

  vars {
    PRM_CODEBUILD_ARTIFACT_BUCKET        = "${aws_s3_bucket.prm-codebuild-artifact.arn}"
    PRM_CODEBUILD_LAMBDA_ARTIFACT_BUCKET = "${aws_s3_bucket.prm-codebuild-lambda-artifact.arn}"
  }
}


resource "aws_iam_role" "cloudwatch-pipeline-role" {
  name               = "cloudwatch-pipeline-role"
  assume_role_policy = "${file("${path.module}/cloudwatch-pipeline-role.json")}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch-service-attachment" {
  role       = "${aws_iam_role.cloudwatch-pipeline-role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch-role-policy.arn}"
}

resource "aws_iam_policy" "cloudwatch-role-policy" {
  name   = "cloudwatch-assume-role-policy"
  policy = "${data.template_file.cloudwatch-pipeline-policy.rendered}"
}
data "template_file" "cloudwatch-pipeline-policy" {
  template = "${file("${path.module}/cloudwatch-pipeline-policy.json")}"

  vars {
    AWS_REGION     = "${var.aws_region}"
    AWS_ACCOUNT_ID = "${data.aws_caller_identity.current.account_id}"
  }
}
