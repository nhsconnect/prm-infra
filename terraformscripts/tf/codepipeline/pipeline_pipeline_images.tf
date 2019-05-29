resource "aws_codepipeline" "images-pipeline" {
  depends_on = ["aws_iam_role_policy_attachment.codepipeline-generic-role-attachment"]

  name     = "prm-images-pipeline"
  role_arn = "${aws_iam_role.codepipeline-generic-role.arn}"

  artifact_store {
    location = "${aws_s3_bucket.prm-codebuild-artifact.bucket}"
    type     = "S3"
  }

  stage {
    name = "source-images-stage"

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
        OAuthToken           = "${data.aws_ssm_parameter.github_token}"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build-images"

    action {
      name            = "Build-terraform-image"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-terraform-image.name}"
      }
    }
      
    action {
      name            = "Build-node-image"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-node-image.name}"
      }
    }

    action {
      name            = "Build-sec-scan-image"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-sec-scan-image.name}"
      }
    }

    action {
      name            = "Build-dep-check-image"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-dep-check-image.name}"
      }
    }
  
    action {
      name            = "Build-terratest-image"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration {
        ProjectName = "${aws_codebuild_project.prm-build-terratest-image.name}"
      }
    }
  }
}
