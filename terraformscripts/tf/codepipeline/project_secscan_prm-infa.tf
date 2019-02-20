# secscan prm-infra projects

resource "aws_codebuild_project" "prm-secscan-prm-infra-scan" {
  name          = "prm-secscan-prm-infra-plan"
  description   = "Scan the prm-infra repo"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "431593652018.dkr.ecr.eu-west-2.amazonaws.com/codebuild/sec-scan:latest"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/secscan_prm-infra_scan.yml"
  }
}
