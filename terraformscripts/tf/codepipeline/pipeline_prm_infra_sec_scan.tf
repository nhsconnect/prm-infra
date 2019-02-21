resource "aws_codepipeline" "prm-infra_sec_scan" {
  #   lifecycle {
  #   ignore_changes = [
  #     "stage.0.action.0.configuration.OAuthToken",
  #     "stage.0.action.0.configuration.%",
  #   ]
  # }

  name     = "prm-infra_sec_scan"
  role_arn = "${aws_iam_role.codepipeline-generic-role.arn}"

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
      output_artifacts = ["source"]

      configuration {
        Owner                = "nhsconnect"
        Repo                 = "prm-infra"
        Branch               = "master"
        OAuthToken           = "${var.github_token}"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Scan_prm-infra_repo"

    action {
      name            = "Scan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-secscan-prm-infra-scan.name}"
      }
    }
  }
}
