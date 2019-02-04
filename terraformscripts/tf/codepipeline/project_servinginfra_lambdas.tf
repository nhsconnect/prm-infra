# prm-servinginfra-lambdas projects

resource "aws_codebuild_project" "prm-servinginfra-lambdas-plan" {
  name          = "prm-servinginfra-lambdas-plan"
  description   = "Validates the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_servinginfra_plan.yml"
  }
}

resource "aws_codebuild_project" "prm-servinginfra-lambdas-apply" {
  name          = "prm-servinginfra-lambdas-apply"
  description   = "Applies the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_servinginfra_apply.yml"
  }
}

resource "aws_codebuild_project" "prm-servinginfra-update-test-project" {
  name          = "prm-servinginfra-update-test-project"
  description   = "Hack to update the codebuild definition for the test with the VPC info"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

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
    buildspec = "./pipeline_definition/opentest_update_test_project.yml"
  }
}

resource "aws_codebuild_project" "prm-servinginfra-lambdas-test" {
  name          = "prm-servinginfra-lambdas-test"
  description   = "Runs E2E tests of the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_servinginfra_test.yml"
  }
}
