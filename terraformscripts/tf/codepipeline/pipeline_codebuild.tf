resource "aws_codepipeline" "prm-codebuild-pipeline" {
  # This lifecycle is here as it's needed to instruct Terraform not to get ruffled when the OAuthToken token differs from the explicited. A solution would be to implement some form  # of secret management and pass the OAuthToken secret down to the Terraform script as a paramenter.  # This lifecycle  statement also need to be commented out when making changes to the pipeline, as the AWS API consider the OAuthToken parameter being not optional.

  lifecycle {
    ignore_changes = ["stage.0.action.0.configuration.OAuthToken", "stage.0.action.0.configuration.%"]
  }

  # Also, terraform fmt will clob the above comments. Enjoy!

  name     = "prm-codepipeline-pipeline"
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

    # Unfortunately multiple sources cannot output in the same outputArtifacts, as documented in https://docs.aws.amazon.com/codepipeline/latest/userguide/reference-pipeline-structure.html
    # This make having both a GitHub and an S3 integration difficult to maintain. My suggestion would be to ditch the GitHub one and pipe everything through S3 via a webhook trigger. 
    # As a side effects we would also get rid of the OAuthToken issue, as there is no way to redefine the pipeline and maintain the secrets in place (even using Terraform), as documented
    # in the aforementioned page. Additionally, we would not need to restore the execute flag which is not preserved with the GitHub integration.

    #action {
    #  name             = "S3Source"
    #  category         = "Source"
    #  owner            = "AWS"
    #  provider         = "S3"
    #  version          = "1"
    #  output_artifacts = ["sourceS3"]

    #  configuration {
    #    S3Bucket             = "${aws_s3_bucket.prm-codebuild-lambda-artifact.id}"
    #    S3ObjectKey          = "prm-infra.zip"
    #    PollForSourceChanges = "false"
    #  }
    #}
  }
  stage {
    name = "Build_Assume_role"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-codebuild-assume-role-plan.name}"
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
        ProjectName = "${aws_codebuild_project.prm-codebuild-assume-role-apply.name}"
      }
    }
  }
  stage {
    name = "Build_Codepipeline"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-codebuild-codepipeline-plan.name}"
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
        ProjectName = "${aws_codebuild_project.prm-codebuild-codepipeline-apply.name}"
      }
    }
  }
  stage {
    name = "Build_Lambdas"

    action {
      name            = "Plan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 1

      configuration {
        ProjectName = "${aws_codebuild_project.prm-codebuild-lambdas-plan.name}"
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
        ProjectName = "${aws_codebuild_project.prm-codebuild-lambdas-apply.name}"
      }
    }

    action {
      name            = "Validate"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]
      run_order       = 3

      configuration {
        ProjectName = "${aws_codebuild_project.prm-codebuild-lambdas-validate.name}"
      }
    }
  }
}
