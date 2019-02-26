resource "aws_ecr_repository" "terraform-image" {
    name = "codebuild/terraform"
}

data "aws_iam_policy_document" "code_build_access" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    principals {
      type = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
  }
}

resource "aws_ecr_lifecycle_policy" "terraform-image" {
  repository = "${aws_ecr_repository.terraform-image.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 1 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "terraform-image" {
    repository = "${aws_ecr_repository.terraform-image.name}"

    policy = "${data.aws_iam_policy_document.code_build_access.json}"
}

resource "aws_codebuild_project" "prm-build-terraform-image" {
  name          = "prm-build-terraform-image"
  description   = "Builds terraform image"
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
      value = "${aws_ecr_repository.terraform-image.name}"
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

resource "aws_ecr_repository" "node-image" {
    name = "codebuild/node"
}

resource "aws_ecr_lifecycle_policy" "node-image" {
  repository = "${aws_ecr_repository.node-image.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 1 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "node-image" {
    repository = "${aws_ecr_repository.node-image.name}"

    policy = "${data.aws_iam_policy_document.code_build_access.json}"
}

resource "aws_codebuild_project" "prm-build-node-image" {
  name          = "prm-build-node-image"
  description   = "Builds node image"
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
      value = "${aws_ecr_repository.node-image.name}"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "IMAGE_DIR"
      value = "node"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/build_image.yml"
  }
}

resource "aws_ecr_repository" "sec-scan-image" {
    name = "codebuild/sec-scan"
}

resource "aws_ecr_lifecycle_policy" "sec-scan-image" {
  repository = "${aws_ecr_repository.sec-scan-image.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 1 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "sec-scan-image" {
    repository = "${aws_ecr_repository.sec-scan-image.name}"

    policy = "${data.aws_iam_policy_document.code_build_access.json}"
}

resource "aws_codebuild_project" "prm-build-sec-scan-image" {
  name          = "prm-build-sec-scan-image"
  description   = "Builds sec-scan image"
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
      value = "${aws_ecr_repository.sec-scan-image.name}"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "IMAGE_DIR"
      value = "sec-scan"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/build_image.yml"
  }
}

resource "aws_ecr_repository" "dep-check-image" {
    name = "codebuild/dep-check"
}

resource "aws_ecr_lifecycle_policy" "dep-check-image" {
  repository = "${aws_ecr_repository.dep-check-image.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 1 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_repository_policy" "dep-check-image" {
    repository = "${aws_ecr_repository.dep-check-image.name}"

    policy = "${data.aws_iam_policy_document.code_build_access.json}"
}

resource "aws_codebuild_project" "prm-build-dep-check-image" {
  name          = "prm-build-dep-check-image"
  description   = "Builds dependency check image"
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
      value = "${aws_ecr_repository.dep-check-image.name}"
    }

    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "IMAGE_DIR"
      value = "dep-check"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "./pipeline_definition/build_image.yml"
  }
}
