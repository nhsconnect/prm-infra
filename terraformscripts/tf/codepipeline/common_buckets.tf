resource "aws_s3_bucket" "prm-codebuild-artifact" {
  bucket        = "prm-${data.aws_caller_identity.current.account_id}-codebuild-artifact"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "prm-codebuild-lambda-artifact" {
  bucket        = "prm-${data.aws_caller_identity.current.account_id}-codebuild-lambda-artifact"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}
