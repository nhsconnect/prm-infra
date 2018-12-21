resource "aws_s3_bucket" "prm-codebuild-artifact" {
  bucket        = "prm-${data.aws_caller_identity.current.account_id}-codebuild-artifact"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}
