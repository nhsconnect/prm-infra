resource "aws_codepipeline" "lambda-pipeline" {
  name     = "lambda-pipeline"
  role_arn = "${aws_iam_role.prm-lambda-codepipeline.arn}"

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
        Owner      = "nhsconnect"
        Repo       = "prm-infra"
        Branch     = "master"
        OAuthToken = "****"
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
