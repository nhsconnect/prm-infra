# secscan prm-migrator projects

resource "aws_codebuild_project" "prm-secscan-prm-migrator-scan" {
  name          = "prm-secscan-prm-migrator-plan"
  description   = "Scan the prm-migrator repo for secrets"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/sec-scan:latest"
    type  = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/secscan_prm-migrator_scan.yml"
  }
}

resource "aws_codebuild_project" "prm-dep-check-prm-migrator" {
  name          = "prm-dep-check-prm-migrator"
  description   = "Run OWASP dependency check on the prm-migrator repo"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/codebuild/dep-check:latest"
    type  = "LINUX_CONTAINER"

    environment_variable {
      name = "REPORT_S3_BUCKET"
      value  = "${aws_s3_bucket.dep-scan-report-bucket.bucket}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/dep-check.yml"
  }

  cache {
    type      = "S3"
    location  = "${aws_s3_bucket.codebuild-cache-bucket.bucket}"
  }
}

resource "aws_s3_bucket" "codebuild-cache-bucket" {
  bucket      = "${var.codebuild-cache-bucket-name}"
}

resource "aws_s3_bucket" "dep-scan-report-bucket" {
  bucket      = "${var.codebuild-dep-scan-report-bucket-name}"

  versioning {
    enabled = true
  }

  noncurrent_version_expiration {
    days    = 90
  }
}
