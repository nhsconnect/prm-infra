resource "aws_codepipeline" "prm-secscan-prm-migrator-pipeline" {
  name     = "prm-secscan-prm-migrator-pipeline"
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
        Repo                 = "prm-migrator"
        Branch               = "master"
        OAuthToken           = "${var.github_token}"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Scan_prm-migrator_repo"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-secscan-prm-migrator-scan.name}"
      }
    }
  }

  stage {
    name = "Scan_prm-migrator_repo_java"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-secscan-prm-migrator-scanjava.name}"
      }
    }
  }
}
