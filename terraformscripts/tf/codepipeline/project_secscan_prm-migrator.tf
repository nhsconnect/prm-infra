# secscan prm-migrator projects

resource "aws_codebuild_project" "prm-secscan-prm-migrator-scan" {
  name          = "prm-secscan-prm-migrator-plan"
  description   = "Scan the prm-infra repo (Python)"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "431593652018.dkr.ecr.eu-west-2.amazonaws.com/codebuild/sec-scan:latest"
    type  = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/secscan_prm-migrator_scan.yml"
  }
}

resource "aws_codebuild_project" "prm-secscan-prm-migrator-scanjava" {
  name          = "prm-secscan-prm-migrator-plan_java"
  description   = "Scan the prm-infra repo (Java)"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/java:openjdk-9"
    type  = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/secscan_prm-migrator_scanjava.yml"
  }
}
