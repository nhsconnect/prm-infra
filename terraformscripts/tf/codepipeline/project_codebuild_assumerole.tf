# Assume-role projects

resource "aws_codebuild_project" "prm-codebuild-assume-role-apply" {

  count = "${var.assume_role}"
  name          = "prm-assume-role-apply"
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
      value = "${data.aws_caller_identity.current.arn}"
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
    buildspec = "./pipeline_definition/assumerole_codebuild_apply.yml"
  }
}
