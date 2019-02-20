# Assume-role projects

resource "aws_codebuild_project" "prm-codebuild-assume-role-apply" {
  name          = "prm-assume-role-apply"
  description   = "Applies the infrastructure"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "431593652018.dkr.ecr.eu-west-2.amazonaws.com/codebuild/terraform:latest"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/assumerole_codebuild_apply.yml"
  }
}
