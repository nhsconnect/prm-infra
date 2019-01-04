resource "aws_codebuild_project" "prm-codebuild-lambdas-plan" {
  name          = "prm-lambdas-plan"
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
    buildspec = "./pipeline_definition/lambdas_codebuild_plan.yml"
  }
}

resource "aws_codebuild_project" "prm-codebuild-lambdas-apply" {
  name          = "prm-lambdas-apply"
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
    buildspec = "./pipeline_definition/lambdas_codebuild_apply.yml"
  }
}

resource "aws_codebuild_project" "prm-codebuild-lambdas-validate" {
  name          = "prm-lambdas-validate"
  description   = "Validate the infrastructure"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/lambdas_codebuild_validate.yml"
  }
}
