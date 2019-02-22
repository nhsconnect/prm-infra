resource "aws_codepipeline" "prm-migrator-sec-scan" {
    lifecycle {
    ignore_changes = [
      "stage.0.action.0.configuration.OAuthToken",
      "stage.0.action.0.configuration.%",
    ]
  }

  name     = "prm-migrator-sec-scan"
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
    name = "Scan-prm-migrator-repo"

    action {
      name            = "Scan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-secscan-prm-migrator-scan.name}"
      }
    }
  }
}
resource "aws_cloudwatch_event_rule" "every_five_minutes_rule_prm_migrator_scan" {
  name                = "every-five-minutes-prm-migrator-scan"
  description         = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
  role_arn = "${aws_iam_role.cloudwatch-pipeline-role.arn}"
}

resource "aws_cloudwatch_event_target" "every_five_minutes_event_target_prm_migrator_scan" {
  rule = "${aws_cloudwatch_event_rule.every_five_minutes_rule_prm_migrator_scan.name}"
  arn  = "${aws_codepipeline.prm-migrator-sec-scan.arn}"
  role_arn = "${aws_iam_role.cloudwatch-pipeline-role.arn}"
}