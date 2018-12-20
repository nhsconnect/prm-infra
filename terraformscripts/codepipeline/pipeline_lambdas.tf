resource "aws_codepipeline" "lambda-pipeline" {
  name     = "lambda-pipeline"
  role_arn = "${aws_iam_role.prm-lambda-codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.prm-codebuild-artifact.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GithubSource"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["github-source"]

      configuration {
        Owner  = "nhsconnect"
        Repo   = "prm-infra"
        Branch = "master"
        OAuthToken = "1234"
      }
    }    
  }

  stage {
    name = "source-lambdas-stage"

    action {
      name             = "source-lambdas-action"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source"]

      configuration {
        S3Bucket    = "${var.prm-application-source-bucket}"
        S3ObjectKey = "source-walking-skeleton-spikes/latest.zip"
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
  }
}
