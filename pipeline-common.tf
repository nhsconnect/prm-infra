resource "aws_s3_bucket" "prm-infra-codepipeline-bucket" {
  bucket        = "prm-infra-codepipeline-bucket"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "prm-codebuild-artifact" {
  bucket        = "prm-codebuild-artifact"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}
