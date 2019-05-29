resource "aws_codepipeline" "prm-infra-sec-scan" {
  name     = "prm-infra-sec-scan"
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
        OAuthToken           = "${data.aws_ssm_parameter.github.value}"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Scan-prm-infra-repo"

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
resource "aws_cloudwatch_event_rule" "every_five_minutes_rule_prm_infra_scan" {
  name                = "every-five-minutes-prm-infra-scan"
  description         = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
  role_arn = "${aws_iam_role.cloudwatch-pipeline-role.arn}"
}

resource "aws_cloudwatch_event_target" "every_five_minutes_event_target_prm_infra_scan" {
  rule = "${aws_cloudwatch_event_rule.every_five_minutes_rule_prm_infra_scan.name}"
  arn  = "${aws_codepipeline.prm-infra-sec-scan.arn}"
  role_arn = "${aws_iam_role.cloudwatch-pipeline-role.arn}"
}
