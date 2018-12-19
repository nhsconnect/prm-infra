resource "aws_codebuild_project" "prm-build-uptime-monitor-lambda" {
  name          = "prm-build-uptime-monitor-lambda"
  description   = "Builds uptime monitoring"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-lambda-build-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_uptime_monitoring.yml"
  }
}

resource "aws_codebuild_project" "prm-build-ehr-extract-lambda" {
  name          = "prm-build-ehr-extract-lambda"
  description   = "Builds EhrExtract"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-lambda-build-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_ehr_extract_handler.yml"
  }
}

resource "aws_codebuild_project" "prm-build-retrieve-status-lambda" {
  name          = "prm-build-retrieve-status-lambda"
  description   = "Builds RetrieveStatus"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-lambda-build-role.arn}"

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
    buildspec = "./pipeline_definition/lambdas_retrieve_status.yml"
  }
}



