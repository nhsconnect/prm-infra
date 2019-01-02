# Codepipeline projects

resource "aws_codebuild_project" "prm-codebuild-codepipeline-plan" {
  name          = "prm-codepipeline-plan"
  description   = "Validates the infrastructure"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

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
    buildspec = "./pipeline_definition/codepipeline_codebuild_plan.yml"
  }
}

resource "aws_codebuild_project" "prm-codebuild-codepipeline-apply" {
  name          = "prm-codepipeline-apply"
  description   = "Applies the infrastructure"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

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
    buildspec = "./pipeline_definition/codepipeline_codebuild_apply.yml"
  }
}
