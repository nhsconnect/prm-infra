resource "aws_codepipeline" "lambda-pipeline" {
  name     = "prm-lambda-pipeline"
  role_arn = "${aws_iam_role.codepipeline-generic-role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.prm-codebuild-artifact.bucket}"
    type     = "S3"
  }

  stage {
    name = "source-lambdas-stage"

    action {
      name             = "GithubSource"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        Owner                = "nhsconnect"
        Repo                 = "prm-migrator"
        Branch               = "master"
        OAuthToken           = "${data.aws_ssm_parameter.github_token.value}"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Scan-dependencies-prm-migrator-repo"

    action {
      name            = "Scan-Dependencies"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      #run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-dep-check-prm-migrator.name}"
      }
    }
  }

  stage {
    name = "Test-Lambdas"

    action {
      name            = "Test-Ehr-Extract"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-test-ehr-extract-lambda.name}"
      }
    }

    action {
      name            = "Test-Retrieve-Status"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-test-retrieve-status-lambda.name}"
      }
    }

    action {
      name            = "Test-Retrieve-Processed-Ehr-Extract"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-test-retrieve-processed-ehr-extract-lambda.name}"
      }
    }

    action {
      name            = "Test-Translator"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-test-translator-lambda.name}"
      }
    }
  }

  stage {
    name = "Build-Lambdas"

    action {
      name            = "Build-Ehr-Extract"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-ehr-extract-lambda.name}"
      }
    }

    action {
      name            = "Build-Uptime-Monitor"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-uptime-monitor-lambda.name}"
      }
    }

    action {
      name            = "Build-Retrieve-Status"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-retrieve-status-lambda.name}"
      }
    }

    action {
      name            = "Build-Retrieve-Processed-Ehr-Extract-Status"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-retrieve-processed-ehr-extract-lambda.name}"
      }
    }

    action {
      name            = "Build-Translator"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-translator-lambda.name}"
      }
    }
  }

  stage {
    name = "E2E-Test-Lambdas"

    action {
      name            = "E2E-Test-Lambdas"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-test-e2e-lambda.name}"
      }
    }
  }
}
