data "aws_caller_identity" "current" {}

data "aws_iam_role" "codebuild_role" {
    name = "codebuild-project-generic-role"
}

resource "aws_codebuild_project" "prm-servinginfra-lambdas-test" {
  name          = "prm-servinginfra-lambdas-test"
  description   = "Runs E2E tests of the infrastructure"
  build_timeout = "5"
  service_role  = "${data.aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/node:latest"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/lambdas_servinginfra_test.yml"
  }

  vpc_config {
      vpc_id = "${var.vpc_id}"

      subnets = ["${slice(split(",", var.vpc_subnet_private_ids), 0, 1)}"]

      security_group_ids = ["${var.vpc_egress_all_security_group}"]
  }
}
