resource "aws_codepipeline" "prm-servinginfra-pipeline" {
  lifecycle {
    ignore_changes = ["stage.0.action.0.configuration.OAuthToken", "stage.0.action.0.configuration.%"]
  }

  name     = "prm-servinginfra-pipeline"
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
        OAuthToken           = "3423423434verydummyvalue345343"
        PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Approve"

    action {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration {
        CustomData = "Approve me!"
      }
    }
  }

  stage {
    name = "Build_network"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-network-plan.name}"
      }
    }

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 2

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-network-apply.name}"
      }
    }
  }

  stage {
    name = "Build_Opentest"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-opentest-plan.name}"
      }
    }

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 2

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-opentest-apply.name}"
      }
    }
  }

  stage {
    name = "Approve_Destroy"

    action {
      name     = "Approve_servinginfra_destroy"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration {
        CustomData = "Approve me!"
      }
    }
  }

  stage {
    name = "Destroy_Opentest"

    action {
      name            = "Destroy_Network"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-opentest-destroy.name}"
      }
    }
  }

  stage {
    name = "Destroy_network"

    action {
      name            = "Destroy_Network"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-network-destroy.name}"
      }
    }
  }
}
