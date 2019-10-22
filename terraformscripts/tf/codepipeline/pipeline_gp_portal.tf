resource "aws_codepipeline" "prm-gp-portal-pipeline" {
  name     = "prm-gp-portal-pipeline"
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
        Repo                 = "prm-deductions-portal-gp-practice"
        Branch               = "master"
        OAuthToken           = "${data.aws_ssm_parameter.github_token.value}"
        PollForSourceChanges = "true"
      }
    }
  }

 stage {
    name = "build-docker-images"

    action {
      name            = "build-gp-portal-image"
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
      name            = "build-gp-portal-image"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source"]

      configuration =  {
        ProjectName = "${aws_codebuild_project.prm-build-gp-portal-image.name}"
      }
    }  
 }
}

resource "aws_codebuild_project" "prm-build-gp-portal-image" {
  name          = "prm-build-gp-portal-image"
  description   = "Builds gp portal image"
  build_timeout = "5"

  service_role = "${aws_iam_role.codebuild-project-generic-role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/docker:17.09.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = "${var.aws_region}"
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }

    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = "${aws_ecr_repository.gp-portal-ecr-repo.name}"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "IMAGE_DIR"
      value = "terraform"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/build_image.yml"
  }
}

resource "aws_ecr_repository" "gp-portal-ecr-repo" {
    name = "deductions/gp-portal"
}