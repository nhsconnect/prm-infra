# Bucket for storing artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "prm-infra-artifacts-${var.environment}"
  acl    = "private"
}

# Role to use for running pipeline
data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "pipeline_role" {
  name               = "infra-pipeline-${var.environment}"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_assume.json}"
}

data "aws_iam_policy_document" "pipeline_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]

    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketVersioning",
    ]

    resources = ["${aws_s3_bucket.artifacts.arn}"]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [
      "${aws_codebuild_project.build.arn}",
      "${aws_codebuild_project.test_update.arn}",
      "${aws_codebuild_project.test.arn}",
    ]
  }
}

resource "aws_iam_role_policy" "pipeline_role_policy" {
  name   = "infra-pipeline"
  role   = "${aws_iam_role.pipeline_role.id}"
  policy = "${data.aws_iam_policy_document.pipeline_role_policy.json}"
}

# Pipeline
resource "aws_codepipeline" "pipeline" {
  name     = "prm-infra-${var.environment}"
  role_arn = "${aws_iam_role.pipeline_role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.artifacts.bucket}"
    type     = "S3"
  }

  stage {
    name = "source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner      = "nhsconnect"
        Repo       = "prm-infra"
        Branch     = "prm-new-infra"
        OAuthToken = "${var.github_token}"
      }
    }
  }

  stage {
    name = "build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.build.name}"
      }
    }
  }

  stage {
    name = "test"

    action {
      name            = "Update_Test_Build"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.test_update.name}"
      }
    }

    action {
      name            = "Test"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 2

      configuration {
        ProjectName = "${aws_codebuild_project.test.name}"
      }
    }
  }
}
