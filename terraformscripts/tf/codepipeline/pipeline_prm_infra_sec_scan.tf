resource "aws_codepipeline" "prm-infra-sec-scan" {
    lifecycle {
    ignore_changes = [
      "stage.0.action.0.configuration.OAuthToken",
      "stage.0.action.0.configuration.%",
    ]
  }

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
        OAuthToken           = "${var.github_token}"
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
resource "aws_cloudwatch_event_rule" "every_five_minutes_rule" {
  name                = "every-five-minutes"
  description         = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "every_five_minutes_event_target" {
  rule = "${aws_cloudwatch_event_rule.every_five_minutes_rule.name}"
  arn  = "${aws_codepipeline.prm-infra-sec-scan.arn}"
  role_arn = "${aws_iam_role.cloudwatch-pipeline-role.arn}"
}

resource "aws_iam_role" "cloudwatch-pipeline-role" {
  name               = "cloudwatch-pipeline-role"
  assume_role_policy = "${file("${path.module}/cloudwatch-pipeline-role.json")}"
}

resource "aws_iam_role_policy_attachment" "cloudwatch-service-attachment" {
  role       = "${aws_iam_role.cloudwatch-pipeline-role.name}"
  policy_arn = "${aws_iam_policy.cloudwatch-role-policy.arn}"
}

data "template_file" "cloudwatch-pipeline-policy" {
  template = "${file("${path.module}/cloudwatch-pipeline-policy.json")}"

  vars {
    AWS_REGION     = "${data.aws_region.current.name}"
    AWS_ACCOUNT_ID = "${data.aws_caller_identity.current.account_id}"
  }
}


resource "aws_iam_policy" "cloudwatch-role-policy" {
  name   = "cloudwatch-assume-role-policy"
  policy = "${data.template_file.cloudwatch-pipeline-policy.rendered}"
}

data "aws_region" "current" {}