# secscan prm-infra projects

resource "aws_codebuild_project" "prm-secscan-prm-infra-scan" {
  name          = "prm-secscan-prm-infra-plan"
  description   = "Scan the prm-infra repo for secrets"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/sec-scan:latest"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/secscan_prm-infra_scan.yml"
  }
}
