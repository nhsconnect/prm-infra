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
    image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/terraform:latest"
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
    buildspec = "./pipeline_definition/network_servinginfra_destroy.yml"
  }
}
