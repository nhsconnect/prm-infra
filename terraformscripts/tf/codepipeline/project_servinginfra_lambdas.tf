# prm-servinginfra-lambdas projects

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
    image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/terraform:latest"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ASSUME_ROLE_NAME"
      value = "${var.role_arn}"
    }

    environment_variable {
      name = "ENVIRONMENT"
      value = "${var.environment}"
    }

    environment_variable {
      name = "ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
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
    image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/terraform:latest"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "ASSUME_ROLE_NAME"
      value = "${var.role_arn}"
    }

    environment_variable {
      name = "ENVIRONMENT"
      value = "${var.environment}"
    }

    environment_variable {
      name = "ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
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
    image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/node:latest"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ASSUME_ROLE_NAME"
      value = "${var.role_arn}"
    }

    environment_variable {
      name = "ENVIRONMENT"
      value = "${var.environment}"
    }

    environment_variable {
      name = "ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/lambdas_servinginfra_test.yml"
  }
}
