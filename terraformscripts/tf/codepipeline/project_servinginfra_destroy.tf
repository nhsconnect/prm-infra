# prm-servinginfra-generic-destroy projects

resource "aws_codebuild_project" "prm-servinginfra-opentest-destroy" {
  name          = "prm-servinginfra-opentest-destroy"
  description   = "Destroy the opentest infrastructure"
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
    buildspec = "./pipeline_definition/opentest_servinginfra_destroy.yml"
  }
}

resource "aws_codebuild_project" "prm-servinginfra-lambdas-destroy" {
  name          = "prm-servinginfra-lambdas-destroy"
  description   = "Destroy the lambdas infrastructure"
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
    buildspec = "./pipeline_definition/lambdas_servinginfra_destroy.yml"
  }
}

resource "aws_codebuild_project" "prm-servinginfra-network-destroy" {
  name          = "prm-servinginfra-network-destroy"
  description   = "Destroy the network infrastructure"
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
    buildspec = "./pipeline_definition/network_servinginfra_destroy.yml"
  }
}
