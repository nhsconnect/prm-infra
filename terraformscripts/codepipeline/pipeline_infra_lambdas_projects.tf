resource "aws_codebuild_project" "prm-infra-lambdas-plan" {
  name          = "prm-lambdas-plan"
  description   = "Validates the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-infra-plan-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_infra_plan.yml"
  }
}

resource "aws_codebuild_project" "prm-infra-lambdas-apply" {
  name          = "prm-lambdas-apply"
  description   = "Applies the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-infra-apply-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_infra_apply.yml"
  }
}

resource "aws_codebuild_project" "prm-infra-lambdas-validate" {
  name          = "prm-lambdas-validate"
  description   = "Validate the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-prm-infra-apply-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_infra_validate.yml"
  }
}
