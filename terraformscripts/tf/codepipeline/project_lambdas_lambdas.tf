resource "aws_codebuild_project" "prm-build-uptime-monitor-lambda" {
  name          = "prm-build-uptime-monitor-lambda"
  description   = "Builds uptime monitoring"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/uptime_monitoring/build_deploy.yml"
  }
}

resource "aws_codebuild_project" "prm-test-ehr-extract-lambda" {
  name        = "prm-test-ehr-extract-lambda"
  description = "Tests EhrExtract"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/ehr_extract_handler/test.yml"
  }
}

resource "aws_codebuild_project" "prm-test-retrieve-status-lambda" {
  name        = "prm-test-retrieve-status-lambda"
  description = "Tests RetrieveStatus"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/retrieve_status/test.yml"
  }
}

resource "aws_codebuild_project" "prm-test-retrieve-processed-ehr-extract-lambda" {
  name        = "prm-test-retrieve-processed-ehr-extract-lambda"
  description = "Tests RetrieveProcessedEhrExtract"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/retrieve_processed_ehr_extract/test.yml"
  }
}

resource "aws_codebuild_project" "prm-test-translator-lambda" {
  name        = "prm-test-translator-lambda"
  description = "Tests Translator"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/translator/test.yml"
  }
}

resource "aws_codebuild_project" "prm-build-ehr-extract-lambda" {
  name          = "prm-build-ehr-extract-lambda"
  description   = "Builds EhrExtract"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/ehr_extract_handler/build_deploy.yml"
  }
}

resource "aws_codebuild_project" "prm-build-retrieve-status-lambda" {
  name          = "prm-build-retrieve-status-lambda"
  description   = "Builds RetrieveStatus"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/retrieve_status/build_deploy.yml"
  }
}

resource "aws_codebuild_project" "prm-build-retrieve-processed-ehr-extract-lambda" {
  name          = "prm-build-retrieve-processed-ehr-extract-lambda"
  description   = "Builds RetrieveProcessedEhrExtract"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/retrieve_processed_ehr_extract/build_deploy.yml"
  }
}

resource "aws_codebuild_project" "prm-build-translator-lambda" {
  name          = "prm-build-translator-lambda"
  description   = "Builds Translator"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./lambda/translator/build_deploy.yml"
  }
}

resource "aws_codebuild_project" "prm-test-e2e-lambda" {
  name         = "prm-test-e2e-lambda"
  description  = "e2e Tests lambdas"
  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:8.11.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./e2e/test.yml"
  }
}
