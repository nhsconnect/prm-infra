resource "aws_codepipeline" "prm-servinginfra-pipeline" {
  lifecycle {
    ignore_changes = [
      # "stage.0.action.0.configuration.OAuthToken",
      # "stage.0.action.0.configuration.%",
    ]
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
        OAuthToken           = "${var.github_token}"
        PollForSourceChanges = "true"
      }
    }
  }

  # stage {
  #   name = "Approve_Infra_Provisioning"


  #   action {
  #     name     = "Approve_Infra_Provisioning"
  #     category = "Approval"
  #     owner    = "AWS"
  #     provider = "Manual"
  #     version  = "1"


  #     configuration {
  #       CustomData = "Approve_Infra_Provisioning"
  #     }
  #   }
  # }

  stage {
    name = "Build_Network"

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
    name = "Build_Lambdas"

    action {
      name            = "Apply"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 2

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-lambdas-apply.name}"
      }
    }

    action {
      name            = "Update_Test_Project"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 3

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-update-test-project.name}"
      }
    }

    action {
      name            = "Test"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 4

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-lambdas-test.name}"
      }
    }
  }
  stage {
    name = "Approve_Infra_Destruction"

    action {
      name     = "Approve_Infra_Destruction"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration {
        CustomData = "Approve_Infra_Destruction"
      }
    }
  }
  stage {
    name = "Destroy_Opentest"

    action {
      name            = "Destroy"
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
    name = "Destroy_Lambdas"

    action {
      name            = "Destroy"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-servinginfra-lambdas-destroy.name}"
      }
    }
  }
  stage {
    name = "Destroy_Network"

    action {
      name            = "Destroy"
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
